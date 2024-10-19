import os
import sys
import json
import urllib.request
import urllib.error
import xml.etree.ElementTree as ET
import tempfile
import subprocess

def call_anthropic_api(prompt, context="", use_smart_model=False):
    url = "https://api.anthropic.com/v1/messages"
    headers = {
        "Content-Type": "application/json",
        "x-api-key": os.environ['ANTHROPIC_API_KEY'],
        "anthropic-version": "2023-06-01"
    }
    data = json.dumps({
        "model": "claude-3-sonnet-20240320" if use_smart_model else "claude-3-haiku-20240307",
        "max_tokens": 1000,
        "messages": [
            {
                "role": "user",
                "content": f"{prompt}\n\n{context}"
            }
        ]
    }).encode('utf-8')

    try:
        with urllib.request.urlopen(urllib.request.Request(url, data=data, headers=headers, method='POST')) as response:
            response_data = json.loads(response.read().decode('utf-8'))
            return response_data['content'][0]['text']
    except urllib.error.HTTPError as e:
        print(f"HTTP Error {e.code}: {e.reason}")
        print(e.read().decode('utf-8'))
        raise
    except urllib.error.URLError as e:
        print(f"URL Error: {e.reason}")
        raise

def extract_xml_content(text, tag):
    try:
        root = ET.fromstring(f"<root>{text}</root>")
        element = root.find(tag)
        if element is not None:
            return element.text.strip()
        raise ValueError(f"No content found for tag: {tag}")
    except ET.ParseError:
        raise ValueError("Invalid XML structure in the response")

def edit_in_editor(content, commented_content=""):
    editor = os.environ.get('EDITOR', 'vim')
    with tempfile.NamedTemporaryFile(mode='w+', suffix=".tmp", delete=False) as tf:
        tf.write(content + '\n\n')
        if commented_content:
            tf.write('\n'.join('# ' + line for line in commented_content.split('\n')))
        tf.flush()
        
        initial_mtime = os.path.getmtime(tf.name)
        subprocess.call([editor, tf.name])
        new_mtime = os.path.getmtime(tf.name)
        
        with open(tf.name, 'r') as f:
            edited_content = f.read().strip()
        
    os.unlink(tf.name)
    
    if new_mtime == initial_mtime or edited_content == content + '\n\n' + '\n'.join('# ' + line for line in commented_content.split('\n')):
        return content
    
    return edited_content
