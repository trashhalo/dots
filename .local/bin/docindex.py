#!/usr/bin/env python3
"""
Document Index CLI - Store and search documents using Lance vector database

This tool uses MLX models for embeddings, enabling fast on-device semantic search
on Apple Silicon. The default model (Qwen3-Embedding-0.6B-4bit-DWQ) is specifically
designed for generating high-quality text embeddings and is quantized for efficiency.

The 4-bit DWQ (Dynamic Weight Quantization) provides an excellent balance between
quality and performance, making it ideal for local semantic search applications.

Run with: uv run docindex.py <command>

Examples:
    # Add a document
    uv run docindex.py add --file paper.pdf --id paper1
    
    # Search with hybrid (semantic + keyword) search
    uv run docindex.py search "machine learning optimization"
    
    # Multi-step search with LLM refinement
    uv run docindex.py search "neural networks" --multistep
    
    # Sync a directory of documents
    uv run docindex.py sync "docs/**/*.pdf"
    
    # Start MCP server for AI assistant integration
    uv run docindex.py mcp
    
MCP Server:
    The MCP (Model Context Protocol) server exposes the search functionality as tools
    that can be used by AI assistants like Claude. Once started, the server provides:
    
    Tools:
    - search_documents: Perform semantic/keyword/hybrid search
    - multistep_search: Multi-step search with query refinement
    - list_documents: List all indexed documents
    - get_document_info: Get document metadata
    
    To use with Claude Desktop or other MCP clients, add this to your config:
    {
      "mcpServers": {
        "docindex": {
          "command": "uv",
          "args": ["run", "docindex.py", "--index", "./myindex.lance", "mcp"]
        }
      }
    }

# /// script
# requires-python = ">=3.8"
# dependencies = [
#   "pylance>=0.33.0",
#   "mlx>=0.19.0",
#   "mlx-lm>=0.19.0",
#   "huggingface-hub>=0.20.0",
#   "transformers>=4.40.0",
#   "unstructured[pdf]>=0.10.0",
#   "langchain>=0.1.0",
#   "pyarrow>=10.0.0",
#   "numpy>=1.21.0",
#   "tqdm>=4.65.0",
#   "safetensors>=0.4.0",
#   "mcp>=0.1.0",
#   "scikit-learn>=1.3.0"
# ]
# ///
"""

import argparse
import json
import os
import sys
import re
import glob
from pathlib import Path
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime
from tqdm import tqdm
import asyncio
import logging

# Core dependencies
import lance
import pyarrow as pa
import pyarrow.compute as pc
import numpy as np
import mlx.core as mx
from mlx_lm import load, generate
from huggingface_hub import snapshot_download
from transformers import AutoTokenizer, AutoConfig
import safetensors
from safetensors import safe_open

# Document processing
from unstructured.partition.auto import partition
from langchain.text_splitter import RecursiveCharacterTextSplitter

# RAPTOR support
from sklearn.mixture import GaussianMixture
from sklearn.preprocessing import StandardScaler

# MCP Server
try:
    from mcp.server import Server, NotificationOptions
    from mcp.server.models import InitializationOptions
    from mcp.types import Tool, TextContent, ToolResponseContent
    MCP_AVAILABLE = True
except ImportError:
    MCP_AVAILABLE = False

# Configuration
DEFAULT_EMBEDDING_MODEL = "mlx-community/Qwen3-Embedding-0.6B-4bit-DWQ"  # Qwen3 MLX embedding model
# Other good MLX embedding models to try:
# - "mlx-community/Qwen3-Embedding-0.6B-8bit" (higher precision version)
# - "mlx-community/snowflake-arctic-embed-s-mlx" (smaller, faster)
# - "mlx-community/bge-small-en-v1.5-mlx" (small but effective)
# - "mlx-community/mxbai-embed-large-v1-mlx" (high quality, larger)
DEFAULT_LLM_MODEL = "mlx-community/gemma-3n-E4B-it-lm-4bit"
DEFAULT_CHUNK_SIZE = 500
DEFAULT_CHUNK_OVERLAP = 50
DEFAULT_INDEX_PATH = "./docindex.lance"


class MLXEmbeddingModel:
    """MLX-based embedding model for document and query embeddings
    
    This class is optimized for MLX embedding models like Qwen3-Embedding,
    which are specifically designed for generating semantic embeddings rather
    than general text generation. The model uses mean pooling over token
    embeddings to create fixed-size sentence representations.
    
    The default Qwen3-Embedding-0.6B-4bit-DWQ model provides:
    - 1536-dimensional embeddings for rich semantic representation
    - 4-bit quantization for efficient memory usage (~150MB)
    - Fast inference on Apple Silicon via MLX
    - High-quality embeddings comparable to much larger models
    """
    
    def __init__(self, model_name: str):
        self.model_name = model_name
        self.model = None
        self.tokenizer = None
        self.config = None
        self.embedding_dim = None
        self._load_model()
    
    def _load_model(self):
        """Load the MLX embedding model"""
        print(f"Loading MLX embedding model: {self.model_name}")
        
        # Load model and tokenizer using mlx_lm (adapted from qwen3-embeddings-mlx)
        from mlx_lm import load
        self.model, self.tokenizer = load(self.model_name)
        
        # Load config to get embedding dimension
        from pathlib import Path
        cache_dir = Path.home() / ".cache" / "huggingface" / "hub"
        model_path = snapshot_download(
            repo_id=self.model_name,
            cache_dir=cache_dir,
            allow_patterns=["*.json"]
        )
        
        config_path = Path(model_path) / "config.json"
        with open(config_path, 'r') as f:
            self.config = json.load(f)
        
        # Get embedding dimension
        self.embedding_dim = self.config.get('hidden_size', 1536)
        
        print(f"Model loaded successfully. Embedding dimension: {self.embedding_dim}")
    
    def _get_hidden_states(self, input_ids: mx.array) -> mx.array:
        """
        Extract hidden states from the model before output projection.
        Adapted from qwen3-embeddings-mlx.
        
        Args:
            input_ids: Token IDs as MLX array [batch_size, seq_len]
            
        Returns:
            Hidden states [batch_size, seq_len, hidden_dim]
        """
        # Get token embeddings
        h = self.model.model.embed_tokens(input_ids)
        
        # Pass through transformer layers
        for layer in self.model.model.layers:
            h = layer(h, mask=None, cache=None)
        
        # Apply final layer normalization
        h = self.model.model.norm(h)
        
        return h

    def encode(self, texts: List[str], show_progress_bar: bool = False, batch_size: int = 32) -> np.ndarray:
        """Generate embeddings for texts using Qwen3 model (adapted from qwen3-embeddings-mlx)"""
        if isinstance(texts, str):
            texts = [texts]
        
        all_embeddings = []
        
        # Process in batches
        for i in tqdm(range(0, len(texts), batch_size), 
                     disable=not show_progress_bar, 
                     desc="Generating embeddings"):
            batch_texts = texts[i:i + batch_size]
            
            batch_embeddings = []
            for text in batch_texts:
                # Tokenize text
                tokens = self.tokenizer.encode(text)
                
                # Truncate if necessary (max 8192 tokens as in the reference)
                if len(tokens) > 8192:
                    tokens = tokens[:8192]
                
                # Convert to MLX array with batch dimension
                input_ids = mx.array([tokens])
                
                # Get hidden states
                hidden_states = self._get_hidden_states(input_ids)
                
                # Mean pooling across sequence dimension
                pooled = mx.mean(hidden_states, axis=1)  # [1, hidden_dim]
                
                # L2 normalize
                norm = mx.linalg.norm(pooled, axis=1, keepdims=True)
                pooled = pooled / mx.maximum(norm, 1e-9)
                
                # Force evaluation and convert to numpy
                mx.eval(pooled)
                embedding = np.array(pooled.tolist()[0], dtype=np.float32)
                batch_embeddings.append(embedding)
            
            all_embeddings.extend(batch_embeddings)
        
        return np.array(all_embeddings, dtype=np.float32)
    
    def get_sentence_embedding_dimension(self) -> int:
        """Return the embedding dimension"""
        return self.embedding_dim


class MultiStepSearchAgent:
    """Multi-step search agent using LLM for query analysis and refinement"""
    
    def __init__(self, llm_model_name: str = DEFAULT_LLM_MODEL):
        self.llm_model_name = llm_model_name
        self.model = None
        self.tokenizer = None
        self._load_llm()
    
    def _load_llm(self):
        """Load the LLM model"""
        print(f"Loading LLM model: {self.llm_model_name}")
        try:
            self.model, self.tokenizer = load(self.llm_model_name)
            print("LLM model loaded successfully")
        except Exception as e:
            print(f"Warning: Could not load LLM model: {e}")
            print("Multi-step search features will be limited")
    
    def analyze_query(self, original_query: str) -> Dict[str, Any]:
        """Analyze the user query and generate search strategy"""
        if not self.model:
            return {
                "search_terms": [original_query],
                "intent": original_query,
                "query_type": "general"
            }
        
        prompt = f"""<start_of_turn>user
Analyze this search query and suggest 2-3 alternative search terms.

Query: "{original_query}"

Respond with JSON:
{{
  "search_terms": ["term1", "term2", "term3"],
  "intent": "what the user is looking for",
  "query_type": "factual" or "conceptual"
}}
<end_of_turn>
<start_of_turn>model
"""
        
        try:
            response = generate(
                self.model,
                self.tokenizer,
                prompt=prompt,
                verbose=False
            )
            
            # Extract JSON from response
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                return json.loads(json_match.group())
        except Exception as e:
            print(f"Query analysis failed: {e}")
        
        # Fallback
        return {
            "search_terms": [original_query],
            "intent": original_query,
            "query_type": "general"
        }
    
    def refine_search_terms(self, original_query: str, initial_results: List[Dict[str, Any]]) -> List[str]:
        """Generate refined search terms based on initial results"""
        if not self.model or not initial_results:
            return [original_query]
        
        # Sample some result text for context
        sample_texts = [r['text'][:200] for r in initial_results[:3]]
        context = "\n".join(sample_texts)
        
        prompt = f"""<start_of_turn>user
Based on these search results, suggest 2-3 refined search terms.

Original query: "{original_query}"

Results preview:
{context}

List search terms (one per line):
<end_of_turn>
<start_of_turn>model
"""
        
        try:
            response = generate(
                self.model,
                self.tokenizer,
                prompt=prompt,
                verbose=False
            )
            
            terms = [line.strip() for line in response.strip().split('\n') if line.strip()]
            return terms[:3] if terms else [original_query]
        except Exception as e:
            print(f"Term refinement failed: {e}")
            return [original_query]
    
    def synthesize_results(self, query: str, results: List[Dict[str, Any]]) -> str:
        """Create a synthesis of the search results"""
        if not self.model or not results:
            return "No synthesis available."
        
        # Prepare context from top results
        context_chunks = []
        for i, result in enumerate(results[:5], 1):
            chunk_text = result['text'][:300]
            if len(result['text']) > 300:
                chunk_text += "..."
            context_chunks.append(f"Source {i}: {chunk_text}")
        
        context = "\n\n".join(context_chunks)
        
        prompt = f"""<start_of_turn>user
Extract and organize the key facts from these sources related to: "{query}"

{context}

List the relevant information found, organized by topic. Focus on facts, numbers, and direct quotes rather than conclusions or interpretations:
<end_of_turn>
<start_of_turn>model
"""
        
        try:
            response = generate(
                self.model,
                self.tokenizer,
                prompt=prompt,
                verbose=False
            )
            return response.strip()
        except Exception as e:
            print(f"Synthesis failed: {e}")
            return "Unable to generate synthesis."
    
    def generate_hypothetical_document(self, query: str) -> str:
        """Generate a hypothetical document that would answer the query (HyDE)"""
        if not self.model:
            return query  # Fallback to original query
        
        prompt = f"""<start_of_turn>user
Write a detailed, helpful document that would answer this question: "{query}"

Include specific facts, numbers, and concrete details. Write as if you're an expert providing a comprehensive answer. Use professional language and include relevant context.

Document:
<end_of_turn>
<start_of_turn>model
"""
        
        try:
            response = generate(
                self.model,
                self.tokenizer,
                prompt=prompt,
                verbose=False
            )
            return response.strip()
        except Exception as e:
            print(f"HyDE generation failed: {e}")
            return query  # Fallback to original query


class RAPTORTreeBuilder:
    """Builds hierarchical RAPTOR tree from document chunks"""
    
    def __init__(self, embedding_model: MLXEmbeddingModel, llm_agent: MultiStepSearchAgent):
        self.embedding_model = embedding_model
        self.llm_agent = llm_agent
        self.n_clusters = 3  # Number of clusters per level
        self.min_cluster_size = 2  # Minimum chunks to form a cluster
    
    def build_tree(self, chunks: List[str], document_id: str) -> List[Dict[str, Any]]:
        """Build RAPTOR tree from chunks and return all nodes"""
        all_nodes = []
        current_level = 0
        
        # Level 0: Original chunks (leaf nodes)
        current_nodes = []
        for i, chunk in enumerate(chunks):
            node = {
                "node_id": f"{document_id}_L0_N{i}",
                "document_id": document_id,
                "level": 0,
                "content": chunk,
                "children": [],
                "chunk_index": i  # For leaf nodes only
            }
            current_nodes.append(node)
            all_nodes.append(node)
        
        # Build higher levels
        while len(current_nodes) > self.min_cluster_size:
            current_level += 1
            next_level_nodes = self._build_next_level(current_nodes, document_id, current_level)
            
            if not next_level_nodes:
                break
            
            all_nodes.extend(next_level_nodes)
            current_nodes = next_level_nodes
        
        return all_nodes
    
    def _build_next_level(self, nodes: List[Dict], document_id: str, level: int) -> List[Dict]:
        """Build one level of the tree through clustering and summarization"""
        if len(nodes) < self.min_cluster_size:
            return []
        
        # Generate embeddings for all nodes
        node_texts = [node["content"] for node in nodes]
        embeddings = self.embedding_model.encode(node_texts, show_progress_bar=False)
        
        # Normalize embeddings for better clustering
        scaler = StandardScaler()
        normalized_embeddings = scaler.fit_transform(embeddings)
        
        # Determine optimal number of clusters (min 2, max n_clusters or len/2)
        n_clusters = min(self.n_clusters, max(2, len(nodes) // 2))
        
        # Cluster using Gaussian Mixture Model with regularization
        try:
            gmm = GaussianMixture(n_components=n_clusters, random_state=42, 
                                 reg_covar=1e-4, covariance_type='full')
            cluster_labels = gmm.fit_predict(normalized_embeddings)
        except Exception as e:
            # If clustering fails, fall back to simple splitting
            print(f"Warning: GMM clustering failed ({e}), using simple grouping")
            cluster_labels = np.array([i % n_clusters for i in range(len(nodes))])
        
        # Group nodes by cluster
        clusters = {}
        for node, label in zip(nodes, cluster_labels):
            if label not in clusters:
                clusters[label] = []
            clusters[label].append(node)
        
        # Create summary nodes for each cluster
        next_level_nodes = []
        for cluster_id, cluster_nodes in clusters.items():
            if len(cluster_nodes) < self.min_cluster_size:
                continue
            
            # Combine content from cluster
            combined_content = "\n\n".join([node["content"][:500] for node in cluster_nodes])
            
            # Generate summary using LLM
            summary = self._generate_cluster_summary(combined_content, level)
            
            # Create new node
            node = {
                "node_id": f"{document_id}_L{level}_N{cluster_id}",
                "document_id": document_id,
                "level": level,
                "content": summary,
                "children": [n["node_id"] for n in cluster_nodes]
            }
            next_level_nodes.append(node)
        
        return next_level_nodes
    
    def _generate_cluster_summary(self, combined_content: str, level: int) -> str:
        """Generate summary for a cluster of nodes"""
        if not self.llm_agent or not self.llm_agent.model:
            # Fallback: simple truncation
            return combined_content[:1000]
        
        prompt = f"""<start_of_turn>user
Summarize the following related text chunks into a cohesive summary. Focus on key themes, facts, and relationships.

Text:
{combined_content[:2000]}

Provide a comprehensive summary (200-400 words):
<end_of_turn>
<start_of_turn>model
"""
        
        try:
            response = generate(
                self.llm_agent.model,
                self.llm_agent.tokenizer,
                prompt=prompt,
                verbose=False,
                max_tokens=500
            )
            return response.strip()
        except Exception as e:
            print(f"Summary generation failed: {e}")
            return combined_content[:1000]  # Fallback


class DocumentIndexer:
    def __init__(self, index_path: str = DEFAULT_INDEX_PATH,
                 model_name: str = DEFAULT_EMBEDDING_MODEL,
                 llm_model_name: str = DEFAULT_LLM_MODEL,
                 enable_multistep: bool = False,
                 load_models: bool = True):
        self.index_path = index_path
        self.model_name = model_name
        self.llm_model_name = llm_model_name
        self.enable_multistep = enable_multistep
        self.dataset = None
        self.raptor_dataset = None  # Separate dataset for RAPTOR nodes
        self.search_agent = None
        self.model = None
        self.embedding_dim = None
        self.raptor_builder = None
        
        # Initialize MLX embedding model only if needed
        if load_models:
            self.model = MLXEmbeddingModel(model_name)
            self.embedding_dim = self.model.get_sentence_embedding_dimension()
            
            # Initialize multi-step search agent if enabled
            if self.enable_multistep:
                self.search_agent = MultiStepSearchAgent(llm_model_name)
            
            # Always initialize RAPTOR builder for indexing
            self.raptor_builder = RAPTORTreeBuilder(self.model, self.search_agent)
        else:
            # Set default embedding dimension for schema (will get actual from existing dataset)
            self.embedding_dim = 1024  # Default for most models
        
        # Initialize or load Lance datasets
        self._init_dataset()
        self._init_raptor_dataset()
    
    def _init_dataset(self):
        """Initialize Lance dataset with proper schema"""
        schema = pa.schema([
            pa.field("document_id", pa.string()),
            pa.field("chunk_id", pa.string()),
            pa.field("text", pa.string()),
            pa.field("embedding", pa.list_(pa.float32(), self.embedding_dim)),  # Fixed-size list
            pa.field("file_path", pa.string()),
            pa.field("chunk_index", pa.int32()),
            pa.field("metadata", pa.string())
        ])
        
        if os.path.exists(self.index_path):
            self.dataset = lance.dataset(self.index_path)
            print(f"Loaded existing index: {self.index_path}")
        else:
            # Create empty dataset
            empty_data = {
                "document_id": pa.array([], type=pa.string()),
                "chunk_id": pa.array([], type=pa.string()),
                "text": pa.array([], type=pa.string()),
                "embedding": pa.array([], type=pa.list_(pa.float32(), self.embedding_dim)),
                "file_path": pa.array([], type=pa.string()),
                "chunk_index": pa.array([], type=pa.int32()),
                "metadata": pa.array([], type=pa.string())
            }
            empty_table = pa.table(empty_data, schema=schema)
            self.dataset = lance.write_dataset(empty_table, self.index_path)
            print(f"Created new index: {self.index_path}")
    
    def _init_raptor_dataset(self):
        """Initialize RAPTOR dataset for hierarchical nodes"""
        raptor_path = self.index_path.replace('.lance', '_raptor.lance')
        
        schema = pa.schema([
            pa.field("node_id", pa.string()),
            pa.field("document_id", pa.string()),
            pa.field("level", pa.int32()),
            pa.field("content", pa.string()),
            pa.field("embedding", pa.list_(pa.float32(), self.embedding_dim)),
            pa.field("children", pa.string()),  # JSON array of child node IDs
            pa.field("chunk_index", pa.int32()),  # Only for level 0 nodes
            pa.field("metadata", pa.string())
        ])
        
        if os.path.exists(raptor_path):
            self.raptor_dataset = lance.dataset(raptor_path)
            print(f"Loaded existing RAPTOR index: {raptor_path}")
        else:
            # Create empty dataset
            empty_data = {
                "node_id": pa.array([], type=pa.string()),
                "document_id": pa.array([], type=pa.string()),
                "level": pa.array([], type=pa.int32()),
                "content": pa.array([], type=pa.string()),
                "embedding": pa.array([], type=pa.list_(pa.float32(), self.embedding_dim)),
                "children": pa.array([], type=pa.string()),
                "chunk_index": pa.array([], type=pa.int32()),
                "metadata": pa.array([], type=pa.string())
            }
            empty_table = pa.table(empty_data, schema=schema)
            self.raptor_dataset = lance.write_dataset(empty_table, raptor_path)
            print(f"Created new RAPTOR index: {raptor_path}")
    
    def _extract_text(self, file_path: str) -> str:
        """Extract text from various file formats"""
        try:
            elements = partition(filename=file_path)
            text = "\n".join([str(element) for element in elements])
            return text
        except Exception as e:
            # Fallback to reading as plain text
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    return f.read()
            except Exception as e2:
                print(f"Failed to extract text from {file_path}: {e2}")
                raise
    
    def _chunk_text(self, text: str, chunk_size: int = DEFAULT_CHUNK_SIZE, 
                   chunk_overlap: int = DEFAULT_CHUNK_OVERLAP) -> List[str]:
        """Split text into overlapping chunks"""
        splitter = RecursiveCharacterTextSplitter(
            chunk_size=chunk_size,
            chunk_overlap=chunk_overlap,
            separators=["\n\n", "\n", ". ", "! ", "? ", " ", ""],
            keep_separator=True
        )
        return splitter.split_text(text)
    
    def add_document(self, file_path: str, document_id: str, 
                    chunk_size: int = DEFAULT_CHUNK_SIZE,
                    chunk_overlap: int = DEFAULT_CHUNK_OVERLAP) -> None:
        """Add or replace a document in the index"""
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")
        
        print(f"Processing document: {file_path}")
        
        # Remove existing document if it exists
        self._remove_document(document_id, quiet=True)
        
        # Extract text
        text = self._extract_text(file_path)
        if not text.strip():
            print(f"Warning: No text extracted from {file_path}")
            return
        
        # Chunk text
        chunks = self._chunk_text(text, chunk_size, chunk_overlap)
        print(f"Created {len(chunks)} chunks")
        
        if not chunks:
            print(f"Warning: No chunks created from {file_path}")
            return
        
        # Generate embeddings
        print("Generating embeddings...")
        embeddings = self.model.encode(chunks, show_progress_bar=True)
        
        # Prepare data for Lance
        records = []
        for i, (chunk, embedding) in enumerate(zip(chunks, embeddings)):
            chunk_id = f"{document_id}_{i}"
            metadata = {
                "original_file": file_path,
                "chunk_size": chunk_size,
                "chunk_overlap": chunk_overlap,
                "total_chunks": len(chunks),
                "created_at": datetime.now().isoformat()
            }
            
            records.append({
                "document_id": document_id,
                "chunk_id": chunk_id,
                "text": chunk,
                "embedding": embedding.astype(np.float32).tolist(),  # Ensure float32
                "file_path": file_path,
                "chunk_index": np.int32(i),  # Ensure int32
                "metadata": json.dumps(metadata)
            })
        
        # Convert to PyArrow table with explicit schema
        # Create the table with explicit schema to ensure correct data types
        embedding_arrays = [record['embedding'] for record in records]
        embedding_column = pa.array(embedding_arrays, type=pa.list_(pa.float32(), self.embedding_dim))
        
        table = pa.table({
            "document_id": [record['document_id'] for record in records],
            "chunk_id": [record['chunk_id'] for record in records], 
            "text": [record['text'] for record in records],
            "embedding": embedding_column,
            "file_path": [record['file_path'] for record in records],
            "chunk_index": pa.array([record['chunk_index'] for record in records], type=pa.int32()),
            "metadata": [record['metadata'] for record in records]
        })
        
        self.dataset = lance.write_dataset(table, self.index_path, mode="append")
        
        # Create FTS index on the text column for keyword search
        try:
            self.dataset.create_scalar_index("text", "INVERTED", name="text_fts", replace=True, with_position=True)
        except Exception as e:
            print(f"Warning: Failed to create FTS index: {e}")
            # This is not critical for basic functionality
        
        print(f"✓ Added {len(records)} chunks for document '{document_id}'")
        
        # Build and index RAPTOR tree
        if self.raptor_builder:
            self._build_and_index_raptor_tree(chunks, document_id, file_path)
    
    def _build_and_index_raptor_tree(self, chunks: List[str], document_id: str, file_path: str) -> None:
        """Build RAPTOR tree and add to raptor dataset"""
        print(f"Building RAPTOR tree for '{document_id}'...")
        
        # Remove existing RAPTOR nodes for this document if they exist
        self._remove_raptor_nodes(document_id, quiet=True)
        
        # Build the tree
        raptor_nodes = self.raptor_builder.build_tree(chunks, document_id)
        
        if not raptor_nodes:
            print(f"Warning: No RAPTOR nodes created for '{document_id}'")
            return
        
        # Generate embeddings for all nodes
        node_texts = [node["content"] for node in raptor_nodes]
        print(f"Generating embeddings for {len(raptor_nodes)} RAPTOR nodes...")
        embeddings = self.model.encode(node_texts, show_progress_bar=True)
        
        # Prepare records for Lance
        records = []
        for node, embedding in zip(raptor_nodes, embeddings):
            metadata = {
                "original_file": file_path,
                "created_at": datetime.now().isoformat(),
                "node_level": node["level"],
                "node_type": "leaf" if node["level"] == 0 else "summary"
            }
            
            records.append({
                "node_id": node["node_id"],
                "document_id": node["document_id"],
                "level": np.int32(node["level"]),
                "content": node["content"],
                "embedding": embedding.astype(np.float32).tolist(),
                "children": json.dumps(node.get("children", [])),
                "chunk_index": np.int32(node.get("chunk_index", -1)),
                "metadata": json.dumps(metadata)
            })
        
        # Convert to PyArrow table
        embedding_arrays = [record['embedding'] for record in records]
        embedding_column = pa.array(embedding_arrays, type=pa.list_(pa.float32(), self.embedding_dim))
        
        table = pa.table({
            "node_id": [record['node_id'] for record in records],
            "document_id": [record['document_id'] for record in records],
            "level": pa.array([record['level'] for record in records], type=pa.int32()),
            "content": [record['content'] for record in records],
            "embedding": embedding_column,
            "children": [record['children'] for record in records],
            "chunk_index": pa.array([record['chunk_index'] for record in records], type=pa.int32()),
            "metadata": [record['metadata'] for record in records]
        })
        
        raptor_path = self.index_path.replace('.lance', '_raptor.lance')
        self.raptor_dataset = lance.write_dataset(table, raptor_path, mode="append")
        
        # Count nodes by level
        level_counts = {}
        for node in raptor_nodes:
            level = node["level"]
            level_counts[level] = level_counts.get(level, 0) + 1
        
        print(f"✓ Added RAPTOR tree with {len(raptor_nodes)} nodes:")
        for level in sorted(level_counts.keys()):
            print(f"  Level {level}: {level_counts[level]} nodes")
    
    def _remove_raptor_nodes(self, document_id: str, quiet: bool = False) -> bool:
        """Remove RAPTOR nodes for a document"""
        if not self.raptor_dataset:
            return False
        
        try:
            existing = self.raptor_dataset.to_table(filter=f"document_id = '{document_id}'")
            if len(existing) == 0:
                return False
            
            node_count = len(existing)
            if not quiet:
                print(f"Deleting {node_count} RAPTOR nodes for '{document_id}'")
            
            self.raptor_dataset.delete(f"document_id = '{document_id}'")
            raptor_path = self.index_path.replace('.lance', '_raptor.lance')
            self.raptor_dataset = lance.dataset(raptor_path)
            
            if not quiet:
                print(f"✓ Deleted {node_count} RAPTOR nodes")
            return True
        except Exception as e:
            if not quiet:
                print(f"Error deleting RAPTOR nodes: {e}")
            return False
    
    def _remove_document(self, document_id: str, quiet: bool = False) -> bool:
        """Remove all chunks for a given document"""
        try:
            # Check if document exists
            existing = self.dataset.to_table(filter=f"document_id = '{document_id}'")
            if len(existing) == 0:
                if not quiet:
                    print(f"Document '{document_id}' not found in index")
                return False
            
            chunk_count = len(existing)
            if not quiet:
                print(f"Deleting document '{document_id}' ({chunk_count} chunks)")
            
            # Delete rows with this document_id
            self.dataset.delete(f"document_id = '{document_id}'")
            self.dataset = lance.dataset(self.index_path)  # Reload dataset
            
            # Also delete RAPTOR nodes
            self._remove_raptor_nodes(document_id, quiet=quiet)
            
            if not quiet:
                print(f"✓ Deleted document '{document_id}'")
            return True
            
        except Exception as e:
            if not quiet:
                print(f"Error deleting document '{document_id}': {e}")
            return False
    
    def delete_document(self, document_id: str) -> bool:
        """Public method to delete a document"""
        return self._remove_document(document_id, quiet=False)
    
    def search(self, query: str, limit: int = 5, search_type: str = "hybrid", 
              multistep: bool = False, hyde: bool = False, raptor: bool = False) -> Dict[str, Any]:
        """Search for documents similar to the query
        
        Args:
            query: Search query
            limit: Number of results to return
            search_type: "semantic", "bm25", or "hybrid"
            multistep: Enable multi-step search with LLM refinement
            hyde: Enable HyDE (Hypothetical Document Embeddings)
            raptor: Enable RAPTOR search (combines HyDE + multistep + hierarchical search)
        """
        if raptor:
            # RAPTOR search combines all techniques with hierarchical retrieval
            return self._raptor_search(query, limit)
        elif multistep and self.search_agent:
            return self._multistep_search(query, limit, search_type)
        elif hyde and self.search_agent:
            return self._hyde_search(query, limit, search_type)
        else:
            results = self._single_step_search(query, limit, search_type)
            return {
                "results": results,
                "synthesis": None,
                "search_steps": [{"query": query, "result_count": len(results)}]
            }
    
    def _single_step_search(self, query: str, limit: int, search_type: str) -> List[Dict[str, Any]]:
        """Single-step search (original functionality)"""
        if search_type == "semantic":
            return self._search_semantic(query, limit)
        elif search_type == "bm25":
            return self._search_bm25(query, limit)
        elif search_type == "hybrid":
            return self._search_hybrid(query, limit)
        else:
            raise ValueError(f"Unknown search type: {search_type}")
    
    def _multistep_search(self, query: str, limit: int, search_type: str) -> Dict[str, Any]:
        """Multi-step search with LLM-guided refinement"""
        search_steps = []
        all_results = {}  # chunk_id -> result mapping to deduplicate
        
        print(f"🔍 Starting multi-step search for: '{query}'")
        
        # Step 1: Analyze the query
        print("📋 Analyzing query...")
        analysis = self.search_agent.analyze_query(query)
        search_steps.append({"step": "analysis", "analysis": analysis})
        
        # Step 2: Initial search with original query
        print(f"🎯 Initial search: '{query}'")
        initial_results = self._single_step_search(query, limit * 2, search_type)
        search_steps.append({
            "step": "initial_search", 
            "query": query, 
            "result_count": len(initial_results)
        })
        
        # Add initial results
        for result in initial_results:
            all_results[result['chunk_id']] = result
        
        # Step 3: Search with alternative terms from analysis
        for i, alt_term in enumerate(analysis.get('search_terms', [])[:2], 1):
            if alt_term.lower() != query.lower():
                print(f"🔄 Alternative search {i}: '{alt_term}'")
                alt_results = self._single_step_search(alt_term, limit, search_type)
                search_steps.append({
                    "step": f"alternative_search_{i}", 
                    "query": alt_term, 
                    "result_count": len(alt_results)
                })
                
                # Add new results
                for result in alt_results:
                    if result['chunk_id'] not in all_results:
                        all_results[result['chunk_id']] = result
        
        # Step 4: If we have some results, try refinement
        if len(all_results) > 0:
            current_results = list(all_results.values())
            refined_terms = self.search_agent.refine_search_terms(query, current_results[:5])
            
            for i, refined_term in enumerate(refined_terms[:2], 1):
                existing_terms = [query.lower()] + [t.lower() for t in analysis.get('search_terms', [])]
                if refined_term.lower() not in existing_terms:
                    print(f"✨ Refined search {i}: '{refined_term}'")
                    refined_results = self._single_step_search(refined_term, limit, search_type)
                    search_steps.append({
                        "step": f"refined_search_{i}", 
                        "query": refined_term, 
                        "result_count": len(refined_results)
                    })
                    
                    # Add new results
                    for result in refined_results:
                        if result['chunk_id'] not in all_results:
                            all_results[result['chunk_id']] = result
        
        # Step 5: Rank final results
        final_results = list(all_results.values())
        final_results.sort(key=lambda x: x.get('score', 0), reverse=True)
        final_results = final_results[:limit]
        
        # Step 6: Generate synthesis
        synthesis = None
        if final_results and self.search_agent:
            print("📝 Generating synthesis...")
            synthesis = self.search_agent.synthesize_results(query, final_results)
        
        return {
            "results": final_results,
            "synthesis": synthesis,
            "search_steps": search_steps
        }
    
    def _hyde_search(self, query: str, limit: int, search_type: str) -> Dict[str, Any]:
        """HyDE (Hypothetical Document Embeddings) search"""
        print(f"🧠 Starting HyDE search for: '{query}'")
        
        # Step 1: Generate hypothetical document
        print("📝 Generating hypothetical document...")
        hypothetical_doc = self.search_agent.generate_hypothetical_document(query)
        print(f"💭 Hypothetical document: {hypothetical_doc[:100]}...")
        
        # Step 2: Search using the hypothetical document
        print("🔍 Searching with hypothetical document...")
        results = self._single_step_search(hypothetical_doc, limit, search_type)
        
        # Step 3: Generate synthesis based on original query and results
        synthesis = None
        if results and self.search_agent:
            print("📝 Generating synthesis...")
            synthesis = self.search_agent.synthesize_results(query, results)
        
        return {
            "results": results,
            "synthesis": synthesis,
            "search_steps": [
                {"query": f"Original: {query}", "result_count": 0},
                {"query": f"HyDE: {hypothetical_doc[:50]}...", "result_count": len(results)}
            ],
            "hyde_document": hypothetical_doc
        }
    
    def _raptor_search(self, query: str, limit: int) -> Dict[str, Any]:
        """RAPTOR search: HyDE + hierarchical retrieval + multi-step refinement"""
        print(f"🦖 Starting RAPTOR search for: '{query}'")
        search_steps = []
        all_results = {}  # chunk_id/node_id -> result mapping
        
        # Step 1: Generate hypothetical document (HyDE)
        print("📝 Generating hypothetical document...")
        hypothetical_doc = None
        if self.search_agent:
            hypothetical_doc = self.search_agent.generate_hypothetical_document(query)
            search_steps.append({"step": "hyde", "query": hypothetical_doc[:50] + "..."})
        
        # Step 2: Search across RAPTOR tree levels
        print("🌳 Searching RAPTOR tree...")
        raptor_results = self._search_raptor_tree(
            hypothetical_doc if hypothetical_doc else query, 
            limit * 3  # Get more results for better coverage
        )
        
        # Add RAPTOR results to all_results
        for result in raptor_results:
            result_id = result.get('node_id', result.get('chunk_id'))
            all_results[result_id] = result
        
        search_steps.append({
            "step": "raptor_tree_search",
            "query": "hierarchical search",
            "result_count": len(raptor_results)
        })
        
        # Step 3: Also search regular index for completeness
        print("🔍 Searching regular index...")
        regular_results = self._single_step_search(query, limit, "hybrid")
        for result in regular_results:
            if result['chunk_id'] not in all_results:
                all_results[result['chunk_id']] = result
        
        search_steps.append({
            "step": "regular_search",
            "query": query,
            "result_count": len(regular_results)
        })
        
        # Step 4: If we have an LLM, do query refinement
        if self.search_agent and len(all_results) > 0:
            current_results = list(all_results.values())[:5]
            refined_terms = self.search_agent.refine_search_terms(query, current_results)
            
            for i, refined_term in enumerate(refined_terms[:2], 1):
                if refined_term.lower() != query.lower():
                    print(f"✨ Refined search {i}: '{refined_term}'")
                    
                    # Search both RAPTOR and regular
                    refined_raptor = self._search_raptor_tree(refined_term, limit)
                    for result in refined_raptor:
                        result_id = result.get('node_id', result.get('chunk_id'))
                        if result_id not in all_results:
                            all_results[result_id] = result
                    
                    search_steps.append({
                        "step": f"refined_raptor_{i}",
                        "query": refined_term,
                        "result_count": len(refined_raptor)
                    })
        
        # Step 5: Rank and select final results
        final_results = list(all_results.values())
        
        # Boost scores for higher-level RAPTOR nodes (they capture more context)
        for result in final_results:
            if 'level' in result and result['level'] > 0:
                result['score'] = result.get('score', 0) * (1.2 ** result['level'])
        
        # Sort by score
        final_results.sort(key=lambda x: x.get('score', 0), reverse=True)
        final_results = final_results[:limit]
        
        # Step 6: Generate synthesis
        synthesis = None
        if final_results and self.search_agent:
            print("📝 Generating synthesis...")
            synthesis = self.search_agent.synthesize_results(query, final_results)
        
        return {
            "results": final_results,
            "synthesis": synthesis,
            "search_steps": search_steps,
            "raptor_levels_used": list(set(r.get('level', 0) for r in final_results if 'level' in r))
        }
    
    def _search_raptor_tree(self, query: str, limit: int) -> List[Dict[str, Any]]:
        """Search across RAPTOR tree nodes"""
        if not self.raptor_dataset:
            return []
        
        # Generate query embedding
        query_embedding = self.model.encode([query])[0]
        
        try:
            # Create vector index if needed
            self.raptor_dataset.create_index("embedding", index_type="IVF_PQ", 
                                            num_partitions=2, num_sub_vectors=16)
        except:
            pass  # Index might already exist
        
        # Perform vector search
        results = self.raptor_dataset.to_table(
            nearest={
                "column": "embedding",
                "q": query_embedding,
                "k": limit
            }
        ).to_pandas()
        
        # Format results
        formatted_results = []
        for _, row in results.iterrows():
            try:
                metadata = json.loads(row["metadata"])
            except:
                metadata = {}
            
            score = 0
            if "_distance" in row:
                score = float(row["_distance"])
            
            formatted_results.append({
                "node_id": row["node_id"],
                "document_id": row["document_id"],
                "level": int(row["level"]),
                "text": row["content"],
                "chunk_index": int(row["chunk_index"]) if row["chunk_index"] >= 0 else None,
                "score": score,
                "score_type": "raptor_semantic",
                "metadata": metadata,
                "children": json.loads(row["children"]) if row["children"] else []
            })
        
        return formatted_results
    
    def _search_semantic(self, query: str, limit: int) -> List[Dict[str, Any]]:
        """Pure semantic search using embeddings"""
        # Generate query embedding
        query_embedding = self.model.encode([query])[0]
        print(f"Query embedding shape: {query_embedding.shape}")
        print(f"Query embedding type: {type(query_embedding)}")
        
        # First try to create vector index if it doesn't exist
        try:
            self.dataset.create_index("embedding", index_type="IVF_PQ", num_partitions=2, num_sub_vectors=16)
            print("Created vector index")
        except Exception as e:
            print(f"Index creation failed (may already exist): {e}")
        
        # Perform vector search using Lance's to_table API with nearest neighbor search
        results = self.dataset.to_table(
            nearest={
                "column": "embedding", 
                "q": query_embedding,  # Pass numpy array directly
                "k": limit
            }
        ).to_pandas()
        
        return self._format_results(results, score_type="semantic")
    
    def _search_bm25(self, query: str, limit: int) -> List[Dict[str, Any]]:
        """Pure BM25 search using Lance's built-in FTS"""
        try:
            # Use Lance's FTS search via to_table with full_text_query
            results = self.dataset.to_table(
                full_text_query=query,
                limit=limit
            ).to_pandas()
            
            return self._format_results(results, score_type="bm25")
        except Exception as e:
            # BM25/FTS is core functionality - fail fast if broken
            raise RuntimeError(f"BM25/FTS search is broken: {e}. This is a critical search component.") from e
    
    def _search_hybrid(self, query: str, limit: int) -> List[Dict[str, Any]]:
        """Hybrid search using RRF (Reciprocal Rank Fusion) of semantic + BM25"""
        # Get more results from each method for better fusion
        semantic_limit = min(limit * 3, 50)
        bm25_limit = min(limit * 3, 50)
        
        # Get results from both methods
        semantic_results = self._search_semantic(query, semantic_limit)
        bm25_results = self._search_bm25(query, bm25_limit)
        
        # Create rank maps
        semantic_ranks = {r["chunk_id"]: i for i, r in enumerate(semantic_results)}
        bm25_ranks = {r["chunk_id"]: i for i, r in enumerate(bm25_results)}
        
        # Combine all unique results
        all_chunk_ids = set(semantic_ranks.keys()) | set(bm25_ranks.keys())
        
        # Create result lookup
        result_lookup = {}
        for r in semantic_results:
            result_lookup[r["chunk_id"]] = r
        for r in bm25_results:
            if r["chunk_id"] not in result_lookup:
                result_lookup[r["chunk_id"]] = r
        
        # Calculate RRF scores
        rrf_results = []
        k = 60  # RRF parameter (commonly used value)
        
        for chunk_id in all_chunk_ids:
            semantic_rank = semantic_ranks.get(chunk_id, float('inf'))
            bm25_rank = bm25_ranks.get(chunk_id, float('inf'))
            
            # RRF formula: 1/(k + rank)
            semantic_score = 1 / (k + semantic_rank) if semantic_rank != float('inf') else 0
            bm25_score = 1 / (k + bm25_rank) if bm25_rank != float('inf') else 0
            
            # Combine scores (equal weighting)
            rrf_score = semantic_score + bm25_score
            
            result = result_lookup[chunk_id].copy()
            result["score"] = rrf_score
            result["score_type"] = "hybrid_rrf"
            result["semantic_rank"] = semantic_rank if semantic_rank != float('inf') else None
            result["bm25_rank"] = bm25_rank if bm25_rank != float('inf') else None
            
            rrf_results.append(result)
        
        # Sort by RRF score and return top results
        rrf_results.sort(key=lambda x: x["score"], reverse=True)
        return rrf_results[:limit]
    
    def _format_results(self, results_df, score_type: str = "semantic") -> List[Dict[str, Any]]:
        """Format pandas results into standardized format"""
        formatted_results = []
        for _, row in results_df.iterrows():
            try:
                metadata = json.loads(row["metadata"])
            except:
                metadata = {}
            
            # Handle different score column names
            score = 0
            if "_distance" in row:
                score = float(row["_distance"])
            elif "_score" in row:
                score = float(row["_score"])
            elif "score" in row:
                score = float(row["score"])
            
            formatted_results.append({
                "document_id": row["document_id"],
                "chunk_id": row["chunk_id"],
                "text": row["text"],
                "file_path": row["file_path"],
                "chunk_index": int(row["chunk_index"]),
                "score": score,
                "score_type": score_type,
                "metadata": metadata
            })
        
        return formatted_results
    
    def list_documents(self) -> List[Dict[str, Any]]:
        """List all documents in the index"""
        # Get unique document IDs
        table = self.dataset.to_table(columns=["document_id", "file_path", "metadata"])
        
        documents = {}
        for row in table.to_pylist():
            doc_id = row["document_id"]
            if doc_id not in documents:
                try:
                    metadata = json.loads(row["metadata"])
                    chunk_count = metadata.get("total_chunks", 0)
                except:
                    chunk_count = 0
                
                documents[doc_id] = {
                    "document_id": doc_id,
                    "file_path": row["file_path"],
                    "chunk_count": chunk_count
                }
        
        return list(documents.values())
    
    def dump_document(self, document_id: str, include_embeddings: bool = False) -> Optional[Dict[str, Any]]:
        """Dump all data for a document as JSON"""
        import json
        
        # Ensure dataset is loaded
        if self.dataset is None:
            if not os.path.exists(self.index_path):
                return None
            self.dataset = lance.dataset(self.index_path)
        
        # Check if document exists
        try:
            # Use string-based filtering instead of compute expressions
            filtered_table = self.dataset.to_table(filter=f"document_id = '{document_id}'")
        except Exception as e:
            print(f"Error filtering dataset: {e}")
            return None
        
        if len(filtered_table) == 0:
            return None
        
        # Get all chunks for the document
        chunks_data = filtered_table.to_pylist()
        
        # Build document data structure
        document_data = {
            "document_id": document_id,
            "file_path": chunks_data[0]["file_path"] if chunks_data else "",
            "total_chunks": len(chunks_data),
            "chunks": []
        }
        
        # Process metadata from first chunk
        if chunks_data:
            try:
                metadata = json.loads(chunks_data[0]["metadata"])
                document_data["metadata"] = metadata
            except:
                document_data["metadata"] = {}
        
        # Add chunk data
        for chunk in chunks_data:
            chunk_data = {
                "chunk_id": chunk["chunk_id"],
                "chunk_index": chunk["chunk_index"],
                "text": chunk["text"],
                "metadata": chunk["metadata"]
            }
            
            if include_embeddings:
                chunk_data["embedding"] = chunk["embedding"]
            
            document_data["chunks"].append(chunk_data)
        
        # Sort chunks by index
        document_data["chunks"].sort(key=lambda x: x["chunk_index"])
        
        return document_data
    
    def sync_documents(self, pattern: str, chunk_size: int = DEFAULT_CHUNK_SIZE,
                      chunk_overlap: int = DEFAULT_CHUNK_OVERLAP, dry_run: bool = False) -> None:
        """Sync multiple documents using glob pattern"""
        # Find all matching files
        files = glob.glob(pattern, recursive=True)
        
        if not files:
            print(f"No files found matching pattern: {pattern}")
            return
        
        print(f"Found {len(files)} files matching pattern")
        
        if dry_run:
            print("\nDry run - would process:")
            for file_path in files:
                doc_id = Path(file_path).stem
                print(f"  {file_path} -> {doc_id}")
            return
        
        # Process each file
        success_count = 0
        for file_path in tqdm(files, desc="Processing documents"):
            try:
                # Generate document ID from filename
                doc_id = Path(file_path).stem
                
                # Skip if it's a directory
                if os.path.isdir(file_path):
                    continue
                
                self.add_document(file_path, doc_id, chunk_size, chunk_overlap)
                success_count += 1
                
            except Exception as e:
                print(f"\nError processing {file_path}: {e}")
                continue
        
        print(f"\n✓ Successfully processed {success_count}/{len(files)} documents")


class MCPDocumentServer:
    """MCP Server that exposes document search functionality as tools"""
    
    def __init__(self, index_path: str = DEFAULT_INDEX_PATH,
                 model_name: str = DEFAULT_EMBEDDING_MODEL,
                 llm_model_name: str = DEFAULT_LLM_MODEL):
        self.indexer = DocumentIndexer(
            index_path=index_path,
            model_name=model_name,
            llm_model_name=llm_model_name,
            enable_multistep=True
        )
        self.server = Server("docindex")
        self.setup_handlers()
    
    def setup_handlers(self):
        """Set up MCP server handlers"""
        
        @self.server.list_tools()
        async def list_tools() -> List[Tool]:
            """List available tools"""
            return [
                Tool(
                    name="search_documents",
                    description="Search for documents using semantic, keyword, or hybrid search",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "query": {
                                "type": "string",
                                "description": "Search query"
                            },
                            "limit": {
                                "type": "number",
                                "description": "Maximum number of results to return",
                                "default": 5
                            },
                            "search_type": {
                                "type": "string",
                                "enum": ["semantic", "bm25", "hybrid"],
                                "description": "Type of search to perform",
                                "default": "hybrid"
                            }
                        },
                        "required": ["query"]
                    }
                ),
                Tool(
                    name="multistep_search",
                    description="Perform multi-step search with LLM-guided query refinement",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "query": {
                                "type": "string",
                                "description": "Search query"
                            },
                            "limit": {
                                "type": "number",
                                "description": "Maximum number of results to return",
                                "default": 5
                            }
                        },
                        "required": ["query"]
                    }
                ),
                Tool(
                    name="list_documents",
                    description="List all documents in the index",
                    inputSchema={
                        "type": "object",
                        "properties": {}
                    }
                ),
                Tool(
                    name="get_document_info",
                    description="Get information about indexed documents",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "document_id": {
                                "type": "string",
                                "description": "Optional document ID to get info for"
                            }
                        }
                    }
                )
            ]
        
        @self.server.call_tool()
        async def call_tool(name: str, arguments: Any) -> List[ToolResponseContent]:
            """Handle tool calls"""
            
            if name == "search_documents":
                query = arguments.get("query")
                limit = arguments.get("limit", 5)
                search_type = arguments.get("search_type", "hybrid")
                
                # Perform search
                results = self.indexer.search(query, limit, search_type, multistep=False)
                
                # Format results for MCP
                response_text = f"Found {len(results['results'])} results for '{query}':\n\n"
                for i, result in enumerate(results['results'], 1):
                    response_text += f"{i}. **{result['document_id']}** (chunk {result['chunk_index']})\n"
                    response_text += f"   Score: {result['score']:.4f} ({result['score_type']})\n"
                    response_text += f"   Text: {result['text'][:200]}...\n\n"
                
                return [TextContent(type="text", text=response_text)]
            
            elif name == "multistep_search":
                query = arguments.get("query")
                limit = arguments.get("limit", 5)
                
                # Perform multi-step search
                results = self.indexer.search(query, limit, "hybrid", multistep=True)
                
                # Format results with synthesis
                response_text = f"Multi-step search for '{query}':\n\n"
                
                # Add synthesis if available
                if results.get("synthesis"):
                    response_text += f"**Synthesis:** {results['synthesis']}\n\n"
                
                # Add search steps info
                if len(results.get("search_steps", [])) > 1:
                    response_text += "**Search steps:**\n"
                    for step in results["search_steps"]:
                        if step.get("query"):
                            response_text += f"- {step.get('step', 'search')}: '{step['query']}' → {step.get('result_count', 0)} results\n"
                    response_text += "\n"
                
                # Add results
                response_text += f"**Top {len(results['results'])} results:**\n\n"
                for i, result in enumerate(results['results'], 1):
                    response_text += f"{i}. {result['document_id']} (chunk {result['chunk_index']})\n"
                    response_text += f"   {result['text'][:200]}...\n\n"
                
                return [TextContent(type="text", text=response_text)]
            
            elif name == "list_documents":
                documents = self.indexer.list_documents()
                
                if not documents:
                    return [TextContent(type="text", text="No documents in index.")]
                
                response_text = f"Index contains {len(documents)} documents:\n\n"
                for doc in documents:
                    response_text += f"- **{doc['document_id']}**\n"
                    response_text += f"  File: {doc['file_path']}\n"
                    response_text += f"  Chunks: {doc['chunk_count']}\n\n"
                
                return [TextContent(type="text", text=response_text)]
            
            elif name == "get_document_info":
                document_id = arguments.get("document_id")
                documents = self.indexer.list_documents()
                
                if document_id:
                    # Get info for specific document
                    doc = next((d for d in documents if d['document_id'] == document_id), None)
                    if doc:
                        response_text = f"Document: {doc['document_id']}\n"
                        response_text += f"File: {doc['file_path']}\n"
                        response_text += f"Chunks: {doc['chunk_count']}\n"
                    else:
                        response_text = f"Document '{document_id}' not found in index."
                else:
                    # General index info
                    total_chunks = sum(doc['chunk_count'] for doc in documents)
                    response_text = f"Index statistics:\n"
                    response_text += f"- Total documents: {len(documents)}\n"
                    response_text += f"- Total chunks: {total_chunks}\n"
                    response_text += f"- Index path: {self.indexer.index_path}\n"
                    response_text += f"- Embedding model: {self.indexer.model_name}\n"
                    response_text += f"- Embedding dimension: {self.indexer.embedding_dim}\n"
                
                return [TextContent(type="text", text=response_text)]
            
            else:
                return [TextContent(type="text", text=f"Unknown tool: {name}")]
    
    async def run(self):
        """Run the MCP server"""
        from mcp.server.stdio import stdio_server
        
        async with stdio_server() as (read_stream, write_stream):
            await self.server.run(
                read_stream,
                write_stream,
                InitializationOptions(
                    server_name="docindex",
                    server_version="1.0.0",
                    capabilities=self.server.get_capabilities(
                        notification_options=NotificationOptions(),
                        experimental_capabilities={}
                    )
                )
            )


def format_search_results(results: List[Dict[str, Any]], verbose: bool = False) -> None:
    """Format and print search results"""
    if not results:
        print("No results found.")
        return
    
    print(f"\nFound {len(results)} results:\n")
    
    for i, result in enumerate(results, 1):
        print(f"{i}. Document: {result['document_id']}")
        if 'file_path' in result:
            print(f"   File: {result['file_path']}")
        if 'level' in result:
            print(f"   RAPTOR Level: {result['level']} ({'summary' if result['level'] > 0 else 'original chunk'})")
        if 'chunk_index' in result and result.get('chunk_index') is not None:
            print(f"   Chunk: {result['chunk_index']}")
        
        score_info = f"{result['score']:.4f} ({result['score_type']})"
        print(f"   Score: {score_info}")
        
        if verbose and result['score_type'] == 'hybrid_rrf':
            sem_rank = result.get('semantic_rank')
            bm25_rank = result.get('bm25_rank')
            if sem_rank is not None:
                print(f"   Semantic rank: {sem_rank}")
            if bm25_rank is not None:
                print(f"   BM25 rank: {bm25_rank}")
        
        # Truncate text for display
        text_preview = result['text'][:200]
        if len(result['text']) > 200:
            text_preview += "..."
        print(f"   Text: {text_preview}")
        print()


def main():
    parser = argparse.ArgumentParser(description="Document Index CLI")
    parser.add_argument("--index", default=DEFAULT_INDEX_PATH, help="Path to Lance index")
    parser.add_argument("--model", default=DEFAULT_EMBEDDING_MODEL, help="Embedding model name")
    
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # Add command
    add_parser = subparsers.add_parser("add", help="Add or replace a document")
    add_parser.add_argument("--file", required=True, help="Path to document file")
    add_parser.add_argument("--id", required=True, help="Document ID")
    add_parser.add_argument("--chunk-size", type=int, default=DEFAULT_CHUNK_SIZE, 
                          help="Chunk size in characters")
    add_parser.add_argument("--chunk-overlap", type=int, default=DEFAULT_CHUNK_OVERLAP, 
                          help="Chunk overlap in characters")
    
    # Search command
    search_parser = subparsers.add_parser("search", help="Search documents")
    search_parser.add_argument("query", help="Search query")
    search_parser.add_argument("--limit", type=int, default=5, help="Number of results")
    search_parser.add_argument("--type", choices=["semantic", "bm25", "hybrid"], default="hybrid", 
                             help="Search type: semantic (embeddings), bm25 (keyword), or hybrid")
    search_parser.add_argument("--multistep", action="store_true", 
                             help="Enable multi-step LLM-guided search")
    search_parser.add_argument("--hyde", action="store_true", 
                             help="Enable HyDE (Hypothetical Document Embeddings) search")
    search_parser.add_argument("--raptor", action="store_true",
                             help="Enable RAPTOR search (combines HyDE + multistep + hierarchical retrieval)")
    search_parser.add_argument("--verbose", action="store_true", 
                             help="Show detailed scoring information")
    
    # List command
    list_parser = subparsers.add_parser("list", help="List all documents")
    
    # Dump command
    dump_parser = subparsers.add_parser("dump", help="Dump all data for a document as JSON")
    dump_parser.add_argument("--id", required=True, help="Document ID to dump")
    dump_parser.add_argument("--include-embeddings", action="store_true", 
                           help="Include embedding vectors in output")
    
    # Delete command
    delete_parser = subparsers.add_parser("delete", help="Delete a document")
    delete_parser.add_argument("--id", required=True, help="Document ID to delete")
    
    # Sync command
    sync_parser = subparsers.add_parser("sync", help="Sync multiple documents using glob pattern")
    sync_parser.add_argument("pattern", help="Glob pattern for files (e.g., 'docs/**/*.pdf')")
    sync_parser.add_argument("--chunk-size", type=int, default=DEFAULT_CHUNK_SIZE, 
                           help="Chunk size in characters")
    sync_parser.add_argument("--chunk-overlap", type=int, default=DEFAULT_CHUNK_OVERLAP, 
                           help="Chunk overlap in characters")
    sync_parser.add_argument("--dry-run", action="store_true", 
                           help="Show what would be processed without actually doing it")
    
    # MCP server command
    mcp_parser = subparsers.add_parser("mcp", help="Start MCP server exposing search tools")
    mcp_parser.add_argument("--llm-model", default=DEFAULT_LLM_MODEL,
                          help="LLM model for multi-step search")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    try:
        # Enable multistep search if requested
        enable_multistep = hasattr(args, 'multistep') and args.multistep
        enable_hyde = hasattr(args, 'hyde') and args.hyde
        enable_raptor = hasattr(args, 'raptor') and args.raptor
        llm_model = getattr(args, 'llm_model', DEFAULT_LLM_MODEL)
        
        # Don't load models for commands that don't need them
        load_models = args.command not in ['dump', 'list', 'delete']
        
        # Enable multistep for HyDE or RAPTOR (needs LLM)
        if enable_hyde or enable_raptor:
            enable_multistep = True
        
        indexer = DocumentIndexer(
            index_path=args.index, 
            model_name=args.model,
            llm_model_name=llm_model,
            enable_multistep=enable_multistep,
            load_models=load_models
        )
        
        if args.command == "add":
            indexer.add_document(args.file, args.id, args.chunk_size, args.chunk_overlap)
        
        elif args.command == "search":
            search_result = indexer.search(
                args.query, 
                args.limit, 
                args.type,
                multistep=getattr(args, 'multistep', False),
                hyde=getattr(args, 'hyde', False),
                raptor=getattr(args, 'raptor', False)
            )
            
            # Display results
            results = search_result["results"]
            synthesis = search_result.get("synthesis")
            search_steps = search_result.get("search_steps", [])
            
            # Show search steps if multi-step and verbose
            if len(search_steps) > 1 and args.verbose:
                print("\n📊 Search steps:")
                for step in search_steps:
                    if step.get("step") == "analysis":
                        analysis = step["analysis"]
                        print(f"  Query analysis: {analysis.get('intent', 'N/A')}")
                        print(f"  Alternative terms: {', '.join(analysis.get('search_terms', []))}")
                    elif "search" in step.get("step", ""):
                        print(f"  {step['step']}: '{step['query']}' → {step['result_count']} results")
                print()
            
            # Show RAPTOR levels if used
            raptor_levels = search_result.get("raptor_levels_used")
            if raptor_levels:
                print(f"\n🦖 RAPTOR levels used: {sorted(raptor_levels)}")
            
            # Show synthesis if available
            if synthesis:
                print(f"\n📝 Synthesis: {synthesis}\n")
            
            # Show individual results
            format_search_results(results, args.verbose)
        
        elif args.command == "list":
            documents = indexer.list_documents()
            if documents:
                print(f"\nFound {len(documents)} documents:\n")
                for doc in documents:
                    print(f"ID: {doc['document_id']}")
                    print(f"File: {doc['file_path']}")
                    print(f"Chunks: {doc['chunk_count']}")
                    print()
            else:
                print("No documents in index.")
        
        elif args.command == "dump":
            document_data = indexer.dump_document(args.id, args.include_embeddings)
            if document_data:
                import json
                print(json.dumps(document_data, indent=2))
            else:
                print(f"Document with ID '{args.id}' not found.")
        
        elif args.command == "delete":
            indexer.delete_document(args.id)
        
        elif args.command == "sync":
            indexer.sync_documents(args.pattern, args.chunk_size, args.chunk_overlap, args.dry_run)
        
        elif args.command == "mcp":
            if not MCP_AVAILABLE:
                print("Error: MCP is not installed. Install it with: pip install mcp")
                sys.exit(1)
            
            print("Starting MCP server...")
            print("Connect to this server using an MCP-compatible client")
            print("Server name: docindex")
            print(f"Index: {args.index}")
            print(f"Embedding model: {args.model}")
            print("\nAvailable tools:")
            print("  - search_documents: Search with semantic/keyword/hybrid search")
            print("  - multistep_search: Multi-step search with LLM refinement")
            print("  - list_documents: List all indexed documents")
            print("  - get_document_info: Get document information")
            print("\nPress Ctrl+C to stop the server")
            
            # Create and run MCP server
            mcp_server = MCPDocumentServer(
                index_path=args.index,
                model_name=args.model,
                llm_model_name=getattr(args, 'llm_model', DEFAULT_LLM_MODEL)
            )
            
            # Run the async server
            try:
                asyncio.run(mcp_server.run())
            except KeyboardInterrupt:
                print("\nMCP server stopped")
    
    except Exception as e:
        import traceback
        print(f"Error: {e}")
        print("Full traceback:")
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
