# AGENTS.md

本文件是本项目（Meilisearch-UI）面向 AI 代理的唯一入口文档。开始任何工作前请先通读本文档。

## 项目简介

Meilisearch-UI 是一个基于 React 的 Meilisearch 管理面板（admin dashboard），支持多实例管理、国际化（en/zh），可通过 Docker 或静态托管部署。纯前端 SPA，无后端服务，所有请求由浏览器直连 Meilisearch 实例。

## 开发命令

```bash
pnpm dev          # 启动开发服务器（端口 24900）
pnpm build        # 生产构建（含后处理脚本）
pnpm build:safe   # TypeScript 类型检查 + 生产构建
pnpm lint         # Biome 代码检查
pnpm preview      # 预览生产构建
```

## 验证要求

- 提交前必须通过 `pnpm lint`（Biome）检查。
- 变更 TypeScript 代码后必须通过 `pnpm build:safe` 验证类型与构建。
- 项目未配置测试框架，不要求运行测试；如引入测试框架，须先补充测试要求至本文档。

## 编码规范

- 代码注释一律使用英文。
- Git commit 使用英文并遵守 Conventional Commits（`feat(module): description`）。
- 文件名使用小写字母加 `-` 连接；TSX 组件文件用 PascalCase 命名（`index.tsx` 除外）。
- 国际化语言标识使用 `zh-CN`、`en-US` 格式。

## 架构速览

- React 18 + TypeScript + Vite；路由 TanStack Router（`src/routes/` 文件路由）；服务端状态 TanStack Query（30s 轮询刷新）；客户端状态 Zustand（持久化到 localStorage）。
- 组件分层：`src/components/{biz,common,block}`（业务 / 通用 / 页面业务块）；自定义 hooks `src/hooks/`；全局状态 `src/store/`；翻译文件 `src/locales/{en,zh}/` 按命名空间拆分。
- 路由动态段：`/ins/$insID/_layout/index/$indexUID/_layout/documents`，`$insID` 为实例 ID，`$indexUID` 为索引 UID。
- i18n 命名空间：common, dashboard, task, key, upload, document, index, instance, header, sys。
- 详细的架构与技术约束见 `.agentdocs/frontend/architecture.md`（修改任何前端代码前必读）。

## 构建与环境变量

- `BASE_PATH` — 自定义部署子路径。
- `SINGLETON_MODE` / `SINGLETON_HOST` / `SINGLETON_API_KEY` — 单例模式预置实例配置。
- 代码分割按 node_modules 包手动分块；编译器使用 SWC；缩进使用 Tab（Biome）。
