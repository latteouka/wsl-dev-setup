# Dev Knowledge Base — Brain Wiki

> **CRITICAL: 開發 session 中自動累積知識到 `~/projects/brain/dev-ref/`。所有 AI agent 必須遵循。**

## 概述

`~/projects/brain/dev-ref/` 是 AI agent 自動維護的開發知識庫（Karpathy LLM Wiki pattern）。
純 agent 使用，人類不讀。一個主題一個檔，持續更新。

## 查找流程

進入任何專案開發時：

1. 讀 `~/projects/brain/dev-ref/_index.md`
2. 找到相關的 `project--*.md` → 了解專案 context
3. 從專案檔的 stack / wikilinks 找到相關技術主題頁
4. 開發過程中遇到問題 → `grep -r` aliases 找相關頁面

### Wikilink Graph Traversal

讀取 dev-ref 頁面時，如果內文包含 `[[topic]]` wikilinks 且與當前問題相關，跟進讀取該頁。最多跳 2 層，避免無限展開。

## 自動寫入觸發時機

> **事件發生當下立即寫入，不要等到 session 結束。** Session 可能隨時中斷（關終端機、crash），延遲寫入 = 知識遺失。

| 時機 | 動作 |
|---|---|
| 踩坑解決後 | 立即新增/更新技術主題頁 Pitfall 段 |
| 發現有效 pattern | 立即新增/更新技術主題頁 Pattern 段 |
| 架構決策後 | 立即新增/更新技術主題頁 Architecture 段 |
| 部署/配置變更 | 立即更新專案檔 Conventions 或 Deployment 段 |
| 功能上線 | 立即更新專案檔 Current State 段 |
| PR review 發現 pitfall | 立即新增技術主題頁 Pitfall 段（review 別人的 code 也是知識來源） |

## 每次 Commit 前的強制檢查

> **CRITICAL: 每次 `git commit` 之前，必須先檢查：這次 commit 有無值得寫入 dev-ref 的知識？**

- 檢查時機：**staging 完、commit 前**——不是做完所有事才回頭看，是每一個 commit 都過一次
- 判斷標準同上「寫入判斷標準」
- 有 → 先寫 dev-ref，再 commit（dev-ref 的寫入不需要額外 commit，brain repo 自己會處理）
- 沒有 → 直接 commit，不需要報告「我檢查過了」
- **為什麼改成 per-commit：** 原本「完成任務前檢查」粒度太粗——一個 feature 可能 10+ commits，做完才檢查時已經忘了中間踩過什麼坑。Per-commit 讓知識在最新鮮的時候被記下來。

## 寫入判斷標準

要記：
- 花超過 10 分鐘才解決的問題
- 下次會再遇到的 pattern（跨專案可複用）
- 需要特定順序或組合才能成功的配置
- 容易忘記的隱性知識

不記：
- 一次性 typo 修正
- 專案 README / CLAUDE.md 已寫過的內容
- 太專案特定、不可能複用的細節

## 寫入流程

1. 判斷知識屬於哪個 topic
2. 檢查 `_index.md` 有無對應頁面
   - 有 → 讀取該頁，追加新段落（`## {Scope}: {標題}`）
   - 沒有 → 建新頁（含 frontmatter），更新 `_index.md`
3. 更新 `_log.md`（最上方 append 一條：`## [YYYY-MM-DD] {create|update} | {topic}`）
4. 如涉及專案狀態 → 同時更新 `project--*.md`

## 技術主題頁 Frontmatter

```yaml
---
topic: {name}
aliases: [alt-name-1, alt-name-2]   # 涵蓋使用者會用的口語、簡稱，方便 grep 命中
scope: [pattern, pitfall, config, architecture, debug, infra]
stack: [tech1, tech2]
projects: [project1, project2]
updated: YYYY-MM-DD
---
```

## 專案檔 Frontmatter

```yaml
---
topic: {project-name}
type: project
stack: [tech1, tech2]
repo: {repo-name}
namespace: {k8s-namespace}
deploy: {deploy-command}
updated: YYYY-MM-DD
---
```

專案檔名用 `project--{name}.md`（雙破折號前綴）。

內文段落：Overview / Conventions / Deployment / Current State / Pitfalls / Preferences。

## 不打擾原則

- 靜默寫入，不問使用者「要不要記？」
- 不在對話中報告寫入動作，除非使用者問
- 不確定要不要記時偏向記（之後 lint 清理）

# Git Conventions

- 簡單改動（config 微調、typo、單檔小修）直接 commit + push main
- 功能性變更或多檔案修改走 PR（開 branch → commit → push → `gh pr create` → 自動 merge）
- Use conventional commits (feat:, fix:, refactor:, test:, docs:)
- Keep commits atomic and focused - each commit should be a single, complete, reversible unit
- One commit = one purpose (separate features, refactors, and unrelated changes)
- Every commit should pass tests and not break the build
- Write descriptive commit messages explaining "why"
- Use `git add -p` for precise staging when needed

## Ship Checklist — PR merge ≠ 部署

> **CRITICAL: 功能性 PR merge 後不算 ship 完成。下列專案必須再跑一次部署指令才會實際生效。**

| 專案類型 | 部署指令 | 備註 |
|---|---|---|
| kymo k3s 上的應用（ptt / setraining / inventory / process-master / 等） | `make app-deploy` | build + push image → apply kustomize → 重啟 deployments |
| chundev.com docker compose（已停用） | `make deploy` | 已遷移，僅作歷史備份 |
| 其他（vercel / cibtools / sharkflo 等） | 看各自 Makefile / GitHub Actions | 多數有 auto-deploy CI |

**標準 ship 流程（kymo k3s 應用）：**

1. PR merge 後立即 `git checkout main && git pull --ff-only origin main`
2. 跑 `make app-deploy`（5–10 分鐘 build + 部署）
3. 驗證 pod 起來：`kubectl get pods -n <ns>` 確認新 pod READY 1/1，無 RESTART
4. 驗證 fix 行為（依 PR 性質跑對應 SQL / endpoint check）
5. 監控接下來一輪 cron 或 worker cycle，確認 log 出現「complete」之類成功訊號

**為何強調：** 2026-05-04 PR #40 merge 後沒 deploy，導致 ip-lift bug 又持續 24 小時才被發現；同日 PR #41 merge 後也忘記 deploy；PR #42 merge 後又忘了一次。每一次都是「以為 merge 就 ship 完了」造成的時間損失。

**Image tag 的陷阱：** kymo k3s 用 `:latest` tag，merge 不會觸發 image rebuild；Kubernetes Deployment 的 imagePullPolicy 也只在 pod 重啟時拉新 image。沒有 `make app-deploy` 永遠跑舊 code。

# 檔案處理備忘

## xlsx 解析

> 直接用 `openpyxl` 可能因 drawing XML（pitchFamily max=52）爆 `ValueError`，遇到就改走 `xlsx2csv`。

**標準流程：**

```bash
# 1. 確認工具（已裝在 ~/Library/Python/3.14/bin/xlsx2csv）
export PATH="$HOME/Library/Python/3.14/bin:$PATH"

# 2. 一次匯出所有工作表到資料夾（-a = all sheets）
xlsx2csv -a input.xlsx /tmp/out_dir

# 3. CSV 通常有大量空欄，用 Python 壓縮後再讀
python3 << 'EOF'
import csv
with open('/tmp/out_dir/Sheet1.csv', encoding='utf-8') as f:
    for i, row in enumerate(csv.reader(f)):
        cleaned = [c.strip() for c in row]
        while cleaned and cleaned[-1] == '':
            cleaned.pop()
        if any(c for c in cleaned):
            print(f"[{i+1}]", " | ".join(cleaned))
EOF
```

**備案（若 xlsx2csv 也失敗）：**
- `soffice --headless --convert-to csv --outdir /tmp/out input.xlsx`（只會匯出第一個 sheet）
- `pip3 install --user --break-system-packages <tool>`（macOS PEP 668 需加旗標）

# ~/projects 總覽

## 跨專案通用工具（Skills）

| 工具 | Skill | 專案位置 | 用途 |
|---|---|---|---|
| 圖片遮蔽 | `/img-redact` | `~/projects/img-redact/` | 遮蔽截圖 IP / hostname |
| Word 生成 | `/docx-engine` | `~/projects/docx-engine/` | 宣告式 Word 文件生成 |

需要時直接呼叫對應 skill 取得使用說明。

## 跨專案參考檔

| 檔案 | 內容 |
|---|---|
| [E2E-PITFALLS.md](E2E-PITFALLS.md) | Playwright E2E 在 CI 上的 7 條坑（rate limit、storageState 污染等） |
| [DEPENDENCY-ALERT.md](DEPENDENCY-ALERT.md) | GitHub repo 對照表 + Dependabot 處理流程 + CI/CD 慣例 |

---

# Development Guidelines

## Smart TDD

### 必須 TDD（先寫測試）

- **計算/公式** — 薪資、稅率分級、會計、日期換算
- **狀態機/流程** — 訂單狀態、簽核流程、對帳規則
- **資料轉換/解析** — CSV import、日期解析、格式化函式
- **演算法** — 排序、媒合、過濾、搜尋
- **Bug fix** — 先寫重現 bug 的測試再修

### 可直接實作（不需 TDD）

- **簡單 CRUD** — 基本增刪改查
- **UI styling** — CSS、layout、間距、顏色
- **配置變更** — env vars、route config、常數
- **一次性腳本** — data migration、batch processing
- **Prisma schema** — 加/改 model 欄位
- **簡單 props 連線** — 元件間傳資料

### 核心原則

- **沒測試 > 爛測試** — 無意義的測試比沒測試更糟（維護成本 + false confidence）
- 開發中經常跑測試
- 確保**複雜商業邏輯**和 bug fix 有測試覆蓋

### Frontend E2E 強制要求

> **CRITICAL: Frontend feature NOT complete without E2E tests.**

- 任何 frontend 相關 feature：**Playwright E2E 為必須**，unit/integration 不夠
- Test stories 寫在 `.claude/dev/e2e.md`，含 scenarios + 結果

文件結構（`.claude/dev/e2e.md`）：

```markdown
# E2E Test Stories and Results

## [Feature Name]

### Test Scenarios

1. **Story:** [描述]
   - **Steps:** [步驟]
   - **Expected Result:** [預期]
   - **Status:** ✅ Passing / ❌ Failing / ⏳ In Progress
   - **Last Updated:** YYYY-MM-DD
```

**E2E 已知坑：** 寫前必看 [E2E-PITFALLS.md](E2E-PITFALLS.md)（rate limit、storageState 污染、waitForFunction、AlertDialog scope 等 7 條）。

## Code Organization & Modularization

- 檔案小且專注（單一職責）
- 每檔 < 200-300 行
- 共用邏輯抽 utility/helper
- 清楚的命名
- 相關功能 group 為 feature module
- **Component/module 入口加 JSDoc：** purpose、`@param`、`@example`、依賴/副作用

## Documentation

- **NEVER** 把 docs 放在 project root — 一律分到適當資料夾
- 命名：
  - **Snapshot / log / report 類** 加日期前綴：`YYYY-MM-DD_filename.md`
    - 例：spec / plan / decision log / meeting notes / experiment report
  - **常駐文件不加日期**（單一 source of truth，會改寫不出新版）：
    - README.md / CLAUDE.md / SKILL.md / Playbook / quick-start / onboarding
    - Style guide / API reference / checklist / glossary
  - **判斷標準：** 未來會「改寫」還是「出新版」？
- 結構：

```
docs/
├── feature-name/
│   ├── README.md          # Feature overview
│   ├── YYYY-MM-DD_*.md    # Related docs
│   └── ...
scripts/
└── YYYY-MM-DD_*.sh        # Scripts also need date prefix
```

- 內容要求：
  - 頂部寫 `**Created**: YYYY-MM-DD`
  - 提供清楚的目錄結構與使用說明
  - 提供範例與 use cases
  - 維護 README.md 導覽

## Contextual CLAUDE.md — Layered Context

> **CRITICAL: Proactively create and maintain CLAUDE.md in important subdirectories.**

在以下層級主動建立 `CLAUDE.md` 摘要重點：

- **Route page folders**（`src/app/**/`）— 路由用途、資料流、相關 API
- **Component folders**（`src/components/*/`）— 設計理由、使用模式、依賴
- **Feature modules**（`src/features/*/` or `src/server/api/routers/`）— 商業邏輯、狀態管理
- **任何 3+ 相關檔案的資料夾** — 開始長大時

內容區段（按需採用）：

```markdown
# [Folder Name]

## Overview
This folder's responsibility and scope.

## Architecture Decisions
- Why this structure/pattern
- Key trade-offs

## File Structure
Each major file's purpose.

## Implemented Features
- ✅ [Feature]
- ⏳ [In progress]
- 📋 [Planned]

## Usage / API
How to use components/functions.

## Dependencies
Other modules, data flow direction.

## Caveats
Pitfalls or special rules.
```

Workflow：
1. 進資料夾前 — check 既有 CLAUDE.md
2. 完成功能後 — 更新或新建
3. 重構時 — 更新所有受影響資料夾的 CLAUDE.md
4. 發現重要資訊時 — 記下來

原則：簡潔實用、只記非顯而易見的、定期清理過時內容、git 版控。

## Tech Stack

- **Framework:** Next.js + T3 Stack
- **API:** tRPC（type-safe）
- **DB:** Prisma ORM
- **Styling:** Tailwind CSS
- **Auth:** better-auth
- **Lang:** TypeScript（strict）
- **Test:** Vitest（unit）+ Playwright（E2E）

## 開新 Next.js / T3 專案

> **CRITICAL: 不要直接 `pnpm create t3-app`。用 `~/projects/t3-template`。**

開新專案時用 `~/projects/t3-template`(已客製好的基底,含 better-auth / shadcn /
Prisma 7 driver-adapter / `@/*` alias / Husky / Prettier 等),不要跑官方
`pnpm create t3-app` 拉一個官方版再 retrofit。

**為什麼**:官方版用 `~/*` alias、Prisma 6、無 better-auth、無 shadcn,跟此倉庫
所有現有 Next.js 專案(`dfaa`、`flow`、`sharkflo`...)的 base 不一致。Retrofit
比 from-scratch 還貴(2026-05-23 pikard 已踩過這個坑、整批重來)。

**How to apply**:

```bash
cp -r ~/projects/t3-template ~/projects/<新案名>
cd ~/projects/<新案名>
rm -rf .git node_modules generated
git init
# 改 package.json name、README 等
pnpm install
```

`~/projects/t3-example` 是已用 template 起好的完整參考實例,有疑問可比對。

## Package Manager

> **CRITICAL: 用對的 package manager。**

- **預設 `pnpm`**，除非 lock file 顯示其他
- 檢查 lock file：`pnpm-lock.yaml` → pnpm；`yarn.lock` → yarn；`bun.lockb`/`bun.lock` → bun
- **NEVER `npm` / `npx`** — 用 `pnpm` / `pnpm dlx`
- **NEVER 混用**

```bash
# ✅
pnpm install
pnpm dlx prisma studio
pnpm tsx scripts/x.ts

# ❌
npm install
npx prisma studio
yarn add zod  # 除非專案用 yarn
```

## Database Connection

> **CRITICAL: 每次成功建立 DB 連線後，必須記到 `.claude/dev/db.md`。**

### Workflow

1. **動工前** — 先讀 `.claude/dev/db.md` 和 `Makefile`
2. **連上後** — 立即更新 `.claude/dev/db.md`
3. 必含資訊：connection string、啟動指令、驗證指令、最近驗證日期

### Makefile 是線索

常見 target：`db-up` / `db-down` / `db-migrate` / `db-connect` / `db-prod-forward`

### 何時更新

初次設定後、切換環境（local ↔ prod）後、修復連線問題後。

## Prisma Scripts

> **CRITICAL: 每次寫成功的 Prisma 腳本必須記到 `.claude/dev/prisma-scripts.md`。**

### 標準結構（Prisma 7）

```typescript
import "dotenv/config"; // ✅ MUST be at the top
import { PrismaClient } from "@prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";
import { Pool } from "pg";

if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL is not defined");
}

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const db = new PrismaClient({ adapter });

async function main() {
  try {
    // query logic
  } catch (error) {
    console.error("Error:", error);
    throw error;
  } finally {
    await db.$disconnect();
    await pool.end();
  }
}

main();
```

### 常見錯誤

- `PrismaClient needs non-empty options` → 沒裝 driver adapter
- `SASL: client password must be a string` → 沒 `import "dotenv/config"`

## Prisma Migration vs Push 判斷規則

> **CRITICAL: 修改 schema 前必須先判斷專案用哪個。**

1. 檢查 `prisma/migrations/`
   - 有歷史 → **必須 `prisma migrate dev`**，不可 `db push`
   - 無歷史 → 可 `db push`（快速開發期）
2. **drift detected 時不要 `migrate reset`**（會清空資料），改：
   - 手動建 migration 目錄 + SQL → `prisma migrate resolve --applied <name>`
3. 新專案起步可 `db push`，但一旦開始用 migration 就不要混用

### Migration 預設走 Prisma 標準流程，不要手寫 SQL 目錄

> **CRITICAL: 加 migration 預設用 `prisma migrate dev --create-only`，不是 `mkdir + 手寫 migration.sql`。**

- **本機 dev**：`pnpm prisma migrate dev --name <slug> --create-only` 讓 Prisma 產 SQL → 人類審查 → `prisma migrate dev` apply
- **Prod**：透過容器內跑 `prisma migrate deploy`（non-interactive、不做 drift check、安全）
- **同一份 migration SQL** 套兩邊，差別只在「誰互動」

**為什麼**：人手寫 SQL 容易漏 `@default(cuid())` 對應的 default、欄位引號跳脫、`@@map` 對應的表名等細節；Prisma 產的 SQL 才是 schema → DB 的權威翻譯。2026-05-24 pikard scan-request feature 因 spec 誤抄「prod 卡 → 一律手寫」被使用者糾正。

**何時才會真的需要手寫**：
- Prisma 完全跑不起來（極少數）
- 需要寫 raw PostGIS / 觸發器 / 純 SQL DDL（schema.prisma 表達不出來的東西）— 這時 `--create-only` 產空 migration 再人工填 SQL

**PostGIS / 其他 Prisma 不支援的型別 drift**：
- `prisma migrate dev` 會偵測到、跳「Drift detected」+「reset? (y/N)」 → **一律回 N**
- `--create-only` 通常會直接產 SQL 跳過 reset 提示
- **檢查產出的 migration.sql 內不可有任何誤動 drift 欄位的 DDL**（例如 `DROP COLUMN "geom"`），有就手動刪掉再 apply

## Dev Server Error Checking

> **CRITICAL: Always verify dev server has no errors.**

- 改動前後檢查 console 與 terminal
- Playwright MCP `browser_console_messages` 驗證 console
- 有 error 立刻修，不可放著
- 有 error 訊息時不能算 feature 完成

## React/Next.js Best Practices

寫/review React/Next.js 時：

- 避免 barrel imports — 直接從 source 檔匯入
- Heavy components 用 dynamic imports
- 並行 async：`Promise.all()`
- `React.cache()` 做 request 去重
- 最小化 client-side JS
- 預設 Server Components
- 優化 bundle size、消除 render waterfalls

## UI/UX Guidelines

- use skill（`/ui-ux-pro-max` / `/web-design-guidelines`）
- Web Interface Guidelines for accessibility
- 響應式設計（所有 breakpoints）
- 語意 HTML
- 鍵盤導航
- 一致的間距與排版
- Core Web Vitals（LCP / FID / CLS）

## shadcn/ui

> **CRITICAL: ALWAYS use shadcn/ui components instead of raw HTML.**

```tsx
// ✅
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { toast } from "sonner";

// ❌
<button className="rounded-lg bg-blue-600 px-4 py-2">Click me</button>
alert("Error occurred");
```

## Code Quality

- ESLint + Prettier
- 自我說明的程式碼（清楚的命名）
- Comment 只寫複雜商業邏輯
- 用 error boundary 妥善處理錯誤
- API 邊界驗證輸入
- Zod schema 做 runtime validation

## Project Structure (T3)

```
src/
├── app/           # Next.js App Router
├── components/    # Reusable UI
├── server/
│   ├── api/       # tRPC routers
│   └── db/        # Prisma schema & client
├── lib/           # Shared utilities
├── hooks/         # Custom hooks
├── types/         # TS types
└── styles/        # Global styles
```

## Testing Strategy

- **Unit:** 商業邏輯、utilities、hooks
- **Integration:** tRPC procedures、API routes
- **E2E:** 關鍵 user flows（Playwright）
- **Component:** UI（Testing Library）

### 反 Pattern（NEVER 寫）

1. **掃檔測試** — 讀 source 檔內容檢查 CSS class、imports、結構
2. **Trivial 常數測試** — 只驗證常數定義
3. **檔案存在測試** — 只檢查檔案/export 存在
4. **過度 mock 的 component 測試** — mock 一切只驗證 render 不爆炸
5. **`@ts-nocheck` 測試** — NEVER 用

### Integration 測試規則

1. **資料隔離** — 用唯一 prefix（`TEST_PREFIX`）只動自己的資料
2. **不可整表操作** — mutations/queries 不可動整張表
3. **完整清理** — afterAll 按 FK 順序刪、try-catch 包覆
4. **自包含** — 不依賴 DB 既有資料、所有先決資料在 beforeAll 建
5. **Session 含權限** — tRPC integration mock session 要給對的權限

### Good Test 檢查單

- [ ] 測 BEHAVIOR，不是 STRUCTURE
- [ ] 清楚的 input → expected output
- [ ] 不讀 source 檔
- [ ] Integration 測試完整資料隔離 + 清理
- [ ] 沒有 `@ts-nocheck` / `@ts-ignore`
