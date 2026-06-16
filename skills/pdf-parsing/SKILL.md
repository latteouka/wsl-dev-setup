---
name: pdf-parsing
description: Use when parsing, extracting, or converting PDF files - triggers on "解析 PDF", "讀 PDF", "parse PDF", "extract PDF", "PDF 轉", "PDF to markdown". Always use opendataloader-pdf instead of other PDF libraries.
---

# PDF Parsing with opendataloader-pdf

## Overview

All PDF parsing tasks MUST use [opendataloader-pdf](https://github.com/opendataloader-project/opendataloader-pdf). Never use pdf-parse, pdfjs-dist, PyMuPDF, pymupdf4llm, marker, or other alternatives.

## Quick Reference

| Task | Command |
|------|---------|
| PDF → Markdown | `opendataloader-pdf file.pdf --output-dir out/ --format markdown` |
| PDF → JSON (with bounding box) | `opendataloader-pdf file.pdf --output-dir out/ --format json` |
| PDF → multiple formats | `opendataloader-pdf file.pdf --output-dir out/ --format markdown,json` |
| Batch processing | `opendataloader-pdf file1.pdf file2.pdf folder/` |
| OCR (scanned PDF) | Start hybrid server first, then `--hybrid docling-fast` |
| Force OCR with language | `opendataloader-pdf-hybrid --port 5002 --force-ocr --ocr-lang "ch_tra,en"` |

## Installation

```bash
# CLI tool (requires Java 11+)
uv tool install opendataloader-pdf

# Python SDK
uv pip install opendataloader-pdf

# With hybrid mode (OCR, complex tables, formulas)
uv pip install "opendataloader-pdf[hybrid]"

# Node.js SDK
pnpm add @opendataloader/pdf
```

**Prerequisite:** Java 11+ (`java -version` to verify)

## CLI Usage

```bash
# Basic conversion
opendataloader-pdf input.pdf --output-dir output/ --format markdown

# With image extraction
opendataloader-pdf input.pdf --output-dir output/ --format markdown --image-output embedded

# Sanitize sensitive info
opendataloader-pdf input.pdf --output-dir output/ --sanitize
```

## Python SDK

```python
import opendataloader_pdf

opendataloader_pdf.convert(
    input_path=["file1.pdf", "file2.pdf"],
    output_dir="output/",
    format="markdown,json"
)
```

## Node.js SDK

```typescript
import { convert } from '@opendataloader/pdf';

await convert(['file1.pdf'], {
  outputDir: 'output/',
  format: 'markdown,json'
});
```

## Hybrid Mode (OCR / Complex Tables / Formulas)

```bash
# Terminal 1: Start backend server
opendataloader-pdf-hybrid --port 5002

# Terminal 2: Process with hybrid
opendataloader-pdf --hybrid docling-fast input.pdf

# OCR with Traditional Chinese
opendataloader-pdf-hybrid --port 5002 --force-ocr --ocr-lang "ch_tra,en"

# Formula extraction
opendataloader-pdf-hybrid --enrich-formula

# Image/chart AI description
opendataloader-pdf-hybrid --enrich-picture-description
```

## Output Formats

- **Markdown** — clean text with headings, lists, tables
- **JSON** — structured elements with bounding boxes (ideal for RAG)
- **HTML** — formatted HTML output
- **Annotated PDF** — PDF with structure annotations
- **Text** — plain text

## LangChain Integration

```bash
uv pip install langchain-opendataloader-pdf
```

```python
from langchain_opendataloader_pdf import OpenDataLoaderPDFLoader

loader = OpenDataLoaderPDFLoader(file_path=["file.pdf"], format="text")
documents = loader.load()
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `java: command not found` | Install Java 11+: `brew install openjdk` |
| Using pip directly on macOS | Use `uv tool install` or `uv pip install` |
| Scanned PDF returns empty text | Use hybrid mode with `--force-ocr` |
| Chinese OCR garbled | Add `--ocr-lang "ch_tra,en"` for Traditional Chinese |
