---
name: handoff
description: Use when the user says "交班", "handoff", "snapshot", "彙整狀態", or wants to capture the current session state for a future session. Generates a structured prompt that helps a new session quickly understand what to look at.
argument-hint: "下一個 session 要做什麼？（選填，會據此裁剪交班內容）"
---

# Handoff — Session Context Snapshot

產出一份結構化的「交班提示詞」，讓新 session 能在 30 秒內知道該看什麼。

如果使用者帶了參數（例：`/handoff 下次要做 deploy`），據此裁剪交班內容，聚焦在與該目標相關的脈絡。

## Core Principle

**交班不是接續工作，是告訴下一個人該看哪裡。** 不需要完整記錄做了什麼，只需要：當前狀態、關鍵檔案、未完成的事。

## Workflow

### 1. 自動蒐集資訊

不要問使用者，直接從環境蒐集：

```bash
# 當前 branch 和未提交的變更
git status
git diff --stat

# 最近的 commit（看做了什麼）
git log --oneline -10

# 專案的 CLAUDE.md（架構上下文）
cat CLAUDE.md

# Memory 檔案（如果有）
cat .claude/projects/*/memory/MEMORY.md
```

### 2. 回顧對話，提取關鍵資訊

從當前對話中整理：

- **正在做什麼**：一句話描述當前任務
- **做到哪了**：哪些完成、哪些進行中
- **關鍵決策**：對話中做的重要決定（特別是使用者的偏好和修正）
- **卡住的地方**：如果有未解決的問題
- **待辦事項**：明確提到但還沒做的事

### 3. 產出交班提示詞

輸出格式（直接貼到新 session 的第一則訊息）：

```markdown
我們正在做 [專案名稱]（[一句話描述]）。以下是完整上下文：

## 專案狀態

[用 2-3 句話描述目前進度和狀態]

## 已完成的大事

1. **[完成項目]** — [一行說明]
2. **[完成項目]** — [一行說明]

## 關鍵決策（這次對話中確認的）

- [決策 1]
- [決策 2]
- [決策 3]

## 目前進度

[具體到哪一頁/哪個檔案/哪個功能]

## 待處理

- [待辦 1]
- [待辦 2]

## 關鍵檔案（新 session 應該先讀的）

- `path/to/file1` — [這個檔案是什麼、為什麼重要]
- `path/to/file2` — [這個檔案是什麼、為什麼重要]

## 建議 Skills

- `/skill-name` — [為什麼下個 session 該用這個 skill]

## 快速指令

```bash
[啟動 dev server 或其他常用指令]
```

請先讀 [最重要的 1-2 個檔案] 了解完整脈絡，再從上次的進度繼續。
```

## 原則

- **不要問使用者要寫什麼** — 你在對話中，自己整理
- **關鍵檔案要精準** — 不是列出所有改過的檔案，是列出新 session「必須先讀」的檔案
- **決策比程式碼重要** — 新 session 可以看 git diff，但看不到對話中的決策和偏好
- **待辦要具體** — 「繼續做」不是待辦，「p.12 的截圖需要替換為真實 Gateway 後台截圖」才是
- **快速指令要能直接跑** — 新 session 貼了就能用

## 不要做的事

- 不要寫成工作日誌（「今天我們做了...」）
- 不要列出所有 git commit（新 session 自己看）
- 不要寫冗長的技術說明（放連結到檔案）
- 不要記錄已經寫在 CLAUDE.md 或 memory 裡的東西
- 不要包含敏感資訊（API keys、passwords、PII）— 交班文件可能被存檔或分享
- 不要重複已存在的 PRD / ADR / issues / commits 內容 — 用路徑或連結引用
