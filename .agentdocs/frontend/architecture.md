# 前端架构

Meilisearch-UI 是纯前端 SPA，用于管理 Meilisearch 实例。修改任何前端代码前必读本文档。

## 产品形态

- 纯客户端应用，无后端服务，所有 API 请求由浏览器直接发往 Meilisearch 实例（官方 JS 客户端）。
- 实例连接配置存储于浏览器 localStorage，清空浏览器数据即丢失；无任何数据上报。
- 两种运行模式：多实例模式（默认）与单例模式（通过 `SINGLETON_HOST` / `SINGLETON_API_KEY` 等环境变量预置唯一实例）。

## 技术栈

- React 18 + TypeScript + Vite，包管理器 pnpm。
- 路由：TanStack Router（文件路由，`src/routes/` 自动生成 `routeTree.gen.ts`）。
- 服务端状态：TanStack Query（默认 30s 轮询刷新，mount / focus / reconnect 时自动重取）。
- 客户端状态：Zustand（`src/store/`，持久化到 localStorage）。
- UI 库：Arco Design（主）+ Semi UI + Mantine + NextUI + Radix，属历史演进形成的混用现状，新组件优先复用已有方案，避免再引入新的 UI 框架。
- 样式：TailwindCSS + UnoCSS + Sass。
- 表单：React Hook Form + Zod。
- 国际化：i18next，仅 en / zh 两种语言，语言标识使用 `zh-CN`、`en-US` 格式。
- 其他：Day.js（日期）、Fuse.js（模糊搜索）、ECharts（图表）。

## 架构约定

### 组件分层

`src/components/` 分为三层：

- `biz/` - 与具体业务功能绑定的业务组件（如 `IndexList`、`CreateIndex`）。
- `common/` - 通用可复用组件（如 `Loader`、`Breadcrumb`、`JsonEditor`）。
- `block/` - 自包含的业务块，对应页面中的完整功能单元（如 `document/search`、`document/upload`）。

### 路由

- 文件路由位于 `src/routes/`，动态段：`$insID`（实例）、`$indexUID`（索引）。
- 典型路径形态：`/ins/$insID/_layout/index/$indexUID/_layout/documents`。

### 数据获取

- 所有 Meilisearch API 调用统一通过 TanStack Query 管理，不落组件 state。
- 数据获取逻辑封装为 `src/hooks/` 中的自定义 hooks（`useMeiliClient`、`useIndexes` 等），命名以 `use` 开头、单一职责。
- Query key 保持统一命名模式。

### 状态管理

- 服务端状态一律走 TanStack Query；能用局部 state 就不进全局。
- 全局客户端状态用 Zustand（`src/store/`）。
- Provider 级状态（错误边界、toast、UI context）位于 `src/providers/`。

### 目录职责

- `src/utils/` - 工具函数（`array.ts`、`file.ts`、`text.ts` 等）。
- `src/lib/` - 功能库（`i18n.ts`、`toast.ts`、`cn.ts` 等）。
- 路径别名 `@/` 映射到 `src/`。

## 领域概念

- **Instance**：Meilisearch 服务器实例，可同时管理多个。
- **Index**：文档集合，类比 SQL 表；**Document**：索引中的 JSON 文档。
- **Primary Key**：文档唯一标识字段。
- **Task**：异步任务（建索引、写文档等），状态含 enqueued / processing / succeeded / failed / canceled。
- **API Key**：访问实例的认证密钥。

## 重要约束

- 未完全响应式，主要面向桌面端使用。
- Meilisearch 实例必须配置 CORS 允许 UI 域名访问，否则浏览器直连请求会被拦截。
- 单例模式下 API Key 会打进前端 bundle，仅限可信内网环境使用。
- API Key 存于 localStorage，对 JS 可见，需注意 XSS 暴露风险。
- 部署形态：`BASE_PATH` 支持子路径部署；Docker 提供 full / lite 两种镜像（lite 不含单例模式）；另支持 Vercel、Netlify。开发与预览端口 24900。
- 浏览器兼容要求：ES2020+、LocalStorage、Fetch API。

## 跨文件行为约定

- **日期显示**：所有日期字段为 null / undefined / 无效值时必须显示占位符（如 `-`），严禁显示 `1970-01-01` 等 epoch 默认值。适用于任务元数据（`enqueuedAt` / `startedAt` / `finishedAt`）、文档字段及 `TimeAgo`、`CountUp` 等时间组件。
- **项目元数据一致性**：作者（eyeix）、仓库地址、Docker 镜像名（eyeix 的 Docker Hub 命名空间）、演示地址（Vercel 部署）在 `package.json`、README（中英双语）、`LICENSE`、源码中必须保持一致，修改任一处需全局同步。
- **i18n**：新增用户可见文案必须同时补充 `src/locales/en/` 与 `src/locales/zh/` 对应命名空间的翻译。
