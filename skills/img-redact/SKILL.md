---
name: img-redact
description: Use when screenshots or images contain sensitive information (IP addresses, hostnames, credentials, internal URLs) that needs to be masked before sharing or including in reports. Triggers on "遮蔽", "redact", "mask IP", "處理截圖", "圖片遮蔽".
---

# img-redact — 圖片敏感資訊遮蔽工具

## Overview

用 Tesseract OCR 定位圖片中的敏感文字（IP、hostname），再用背景色方塊覆蓋。支援全遮蔽和部分遮蔽（只遮 IP 某一段）。

工具位置：`~/projects/img-redact/redact.py`

## Dependencies

```bash
brew install tesseract
pip3 install pytesseract Pillow --break-system-packages
```

## Quick Reference

| 用途 | 指令 |
|------|------|
| 遮蔽所有 IP | `python3 redact.py image.png --ip-only` |
| 部分遮蔽 IP 第三段 | `python3 redact.py image.png --partial --octets 2` |
| 遮蔽 IP + hostname | `python3 redact.py image.png --partial --octets 2 --patterns "hostname-keyword"` |
| 指定輸出路徑 | `-o output.png` |
| Debug OCR 結果 | `--debug` |
| 自訂遮蔽顏色 | `--color "0,0,0"` （預設 auto 偵測背景色）|

## Core Usage Pattern

### 1. 部分遮蔽 IP（最常用）

遮蔽 IP 第三段，保留辨識性（`192.168.█.57`）：

```bash
python3 ~/projects/img-redact/redact.py screenshot.png \
  --partial --octets 2 \
  --patterns "infominer" "ubuntu@" \
  -o screenshot_redacted.png
```

- `--partial` + `--octets 2`：只遮 IP 的第三段（0-based index）
- `--patterns`：額外遮蔽含指定關鍵字的文字區塊（hostname、prompt 等）
- IP 用部分遮蔽，非 IP pattern 用完整遮蔽

### 2. 完整遮蔽所有 IP

```bash
python3 ~/projects/img-redact/redact.py screenshot.png --ip-only
```

### 3. 同時遮蔽多種敏感資訊

```bash
python3 ~/projects/img-redact/redact.py screenshot.png \
  --ip-only \
  --patterns "hostname" "username" "password" \
  --hosts "server-name-1,server-name-2"
```

## Workflow for Reports

1. **Debug 先確認 OCR** — 加 `--debug` 看 OCR 抓到哪些文字和座標
2. **選擇遮蔽策略** — 報告用 `--partial`（保留辨識性），外部分享用 `--ip-only`（完整遮蔽）
3. **處理殘留** — OCR 可能漏抓某些文字（低對比、截斷），用 Pillow 手動補遮：

```python
from PIL import Image, ImageDraw
img = Image.open("redacted.jpg")
draw = ImageDraw.Draw(img)
draw.rectangle([x1, y1, x2, y2], fill=(bg_r, bg_g, bg_b))
img.save("redacted.jpg")
```

## Common Issues

| 問題 | 解法 |
|------|------|
| hostname 沒被遮蔽 | OCR 可能拆開文字，用 `--patterns` 匹配部分關鍵字 |
| 底部 prompt 殘留 | OCR 信心度低時會漏，用 Pillow 手動補遮 |
| 遮蔽色不對 | `--color auto` 通常可行，不行時手動指定 RGB |
| 圖片邊緣文字漏抓 | Tesseract 對邊緣和低對比文字辨識率較低，需手動處理 |
