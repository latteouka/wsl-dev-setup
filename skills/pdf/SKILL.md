---
name: pdf
description: Use when generating PDF from Markdown files. Triggers on "轉 PDF", "產 PDF", "輸出 PDF", "markdown to pdf", "md to pdf", "export pdf".
---

# pdf — Markdown 轉 PDF（vivliostyle 引擎）

## Overview

將 Markdown 檔案轉換為**排版良好**的 PDF，用途：技術文件、標案材料、簡報稿、規格書。

- **引擎**：[@vivliostyle/cli](https://github.com/vivliostyle/vivliostyle-cli)（日本團隊，CSS Paged Media 實作度最完整，2026 仍活躍開發）
- **Theme**：此 skill 內建的 `theme.css`，為繁體中文 + emoji 場景調校
- **支援功能**：章節分頁、運行頁眉、頁碼、跨頁 thead 重複、widow/orphan 控制、彩色 emoji（macOS）

## 依賴安裝

**在目標專案**內（不要全域裝，避免版本鎖定問題）：

```bash
pnpm add -D @vivliostyle/cli
```

目標專案若要長期使用，建議在 `package.json` 加 script：

```json
{
  "scripts": {
    "print": "vivliostyle build"
  }
}
```

## 使用方式

### 方式 A：一次性轉檔（適合 ad-hoc）

```bash
cd <專案目錄>
pnpm exec vivliostyle build <file.md> \
  --theme ~/projects/dotfiles/skills/pdf/theme.css \
  --output <output.pdf> \
  --size A4 \
  --language zh-Hant \
  --title "<文件標題>"
```

### 方式 B：config file（適合專案長期使用）

在專案根目錄建 `vivliostyle.config.js`：

```js
import { defineConfig } from '@vivliostyle/cli';

export default defineConfig({
  title: '文件標題',
  language: 'zh-Hant',
  size: 'A4',
  entry: 'path/to/file.md',
  theme: '/Users/<username>/projects/dotfiles/skills/pdf/theme.css',
  output: 'dist/output.pdf',
});
```

然後執行：

```bash
pnpm exec vivliostyle build
# 或 pnpm print（若有設 script）
```

> **Theme 路徑**：建議用絕對路徑（`~` 要展開成 `/Users/...`，vivliostyle config 內不解析 `~`）。避免相對路徑因工作目錄變化出問題。

## 驗證清單（產出後一定要跑）

PDF 產出 ≠ 品質 OK。逐項確認：

- [ ] **Emoji 彩色**：🛡️💪💰🤝 不是黑白 / 方框（人工檢視 PDF）
- [ ] **繁中無豆腐**：`pdftotext <pdf> -` 搜尋不該有 `□` / replacement chars
- [ ] **章節分頁**：每個 `# H1` 從新頁開始
- [ ] **Thead 跨頁重複**：長表格每頁上方都有 header row
- [ ] **Code block 不爛**：等寬字型、長行自動換行、不切出邊界
- [ ] **頁碼存在**：每頁有 `X / Y` 格式
- [ ] **字型嵌入**：`pdffonts <pdf>` 輸出所有 CJK 字型 `emb=yes`
- [ ] **檔案大小合理**：300KB ~ 2MB（太小代表字型沒嵌入；太大代表有冗餘）

## 用法範例

使用者說「轉 PDF」或「輸出 PDF」時：

1. 確認目標 `.md` 檔案路徑
2. 檢查專案有沒有裝 `@vivliostyle/cli`（沒裝就 `pnpm add -D`）
3. 執行上方 A 或 B 方式
4. 跑**驗證清單**
5. 回報 PDF 路徑、頁數、檔案大小、驗證結果

## Notes

### 為什麼選 vivliostyle over md-to-pdf？（2026-04-21 架構決策）

舊的實作用 `md-to-pdf`（Puppeteer 包皮），限制：
- 缺 `@page` margin-box 支援 → 做不出運行頁眉 / 自訂頁碼
- 缺 `string-set` → 做不出「當前章節在頁眉」
- CSS Paged Media 只實作基本款 → `break-before: page` 偶發失效
- 2024 後幾乎不更新，技術債堆積

vivliostyle-cli 優勢：
- 用自家 Vivliostyle.js 實作完整 CSS Paged Media Level 3
- 日本團隊 → CJK / 日文直排 / 書籍排版一等公民
- 2026 仍活躍開發（v10.5 / Vivliostyle.js core v2.41）
- 支援 config file → 專案可版控設定
- Theme 可 npm 套件化 → 未來可抽出通用 theme repo

### 已知限制 / 踩坑（給未來 session 留線索）

**2026-04-21 qa-viewer 整合實測驗收結果**：A4 / 11 頁 / 1.48MB，
所有 emoji 彩色、PingFang TC 完整嵌入、4 大章節各自分頁、0 個豆腐字。

1. **Emoji 彩色問題**：Chromium issue #921585 會讓某些 emoji 在 PDF 變黑白。
   - **macOS 實測 OK**（Apple Color Emoji 字型可被嵌入，`pdffonts` 看得到
     `BAAAAA+AppleColorEmoji CID TrueType emb=yes`）
   - Linux CI 若要彩色 emoji，需額外裝 `fonts-noto-color-emoji` 套件
2. **Theme 路徑解析**：vivliostyle 的內建 HTTP server serves `entryContextDir`，
   當 theme 是專案外絕對路徑時會 404。解法：在專案內放 theme（可用 script
   從 dotfiles 複製保持 single source of truth，見 qa-viewer 的 `copy-theme.mjs`）
3. **⚠️ `:first-of-type` 踩坑**：vivliostyle 用 vfm 把 markdown 轉出帶
   `<section class="level1">` wrapper 的 HTML。每個 h1 都在自己的 section 裡，
   所以 `h1:first-of-type` 會**命中所有 h1**！首頁豁免要用
   `body > section:first-of-type > h1` 才對（theme.css 已修正）
4. **長表格**：`thead { display: table-header-group }` 是跨頁重複 header 的關鍵，
   不是 `page-break-before` 能解決的
5. **Type 3 bitmap font**：PingFang TC 在 Skia 的 PDF backend 偶爾會被 rasterize
   成 Type 3 字型（`Bad bounding box in Type 3 glyph` 是 pdftoppm 預覽時的 warning，
   不影響 PDF 文件品質和 pdftotext 抽取）
6. **vivliostyle v10+ 會誤觸 vite build**：偵測到 `vite.config.*` 就先跑 `vite build`
   再產 PDF。多花 1-2 秒但不影響結果
7. **舊版備份**：`print.css.md-to-pdf.bak` 保留在同目錄，必要時可回滾

### 架構決策時間線

- **2026-04-21** 從 md-to-pdf 升級到 vivliostyle-cli v10.5 + Vivliostyle.js v2.41
  - 動機：原 md-to-pdf 缺 @page margin-box / string-set / 完整 CSS Paged Media
  - 驗收：qa-viewer 的 `10-meta-framework.md`（14KB, 繁中+大量 emoji+20+ 表格）
    產出 11 頁 1.48MB 的 PDF，所有驗證項通過
