; extends

; Markdown sections (heading + content including subsections)
(section) @section.outer

; Just the heading content
(atx_heading
  heading_content: (_) @section.inner)

(setext_heading
  heading_content: (_) @section.inner)
