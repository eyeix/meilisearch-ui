# AGENTS.md

## 验证要求

- 提交前必须通过 `pnpm lint`（Biome）检查。
- 变更 TypeScript 代码后必须通过 `pnpm build:safe`（tsc + vite build）验证类型与构建。
- 项目未配置测试框架，不要求运行测试；如引入测试框架，须先补充测试要求至本文档。

## 必读文档

- 修改任何前端代码前，先阅读 `.agentdocs/frontend/architecture.md`。
