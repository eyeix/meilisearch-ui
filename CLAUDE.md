# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Meilisearch-UI is a React-based admin dashboard for managing Meilisearch search engine instances. It supports multi-instance management, internationalization (en/zh), and can be deployed via Docker or static hosting.

## Development Commands

```bash
pnpm dev          # Start dev server (port 24900)
pnpm build        # Production build with post-processing
pnpm build:safe   # TypeScript check + build
pnpm lint         # Run Biome linter
pnpm preview      # Preview production build
```

**Note:** No test framework is configured.

## Architecture

### Tech Stack
- **Framework:** React 18 + TypeScript + Vite
- **Routing:** TanStack Router (file-system based)
- **State:** TanStack Query (server state) + Zustand (client state, persisted to localStorage)
- **UI:** Mixed - Arco Design, Semi UI, Mantine, NextUI, Radix
- **Styling:** TailwindCSS + UnoCSS + Sass
- **i18n:** i18next with custom language detector

### Key Directories
- `src/routes/` - File-system routing (auto-generates `routeTree.gen.ts`)
- `src/components/common/` - Reusable UI components
- `src/components/biz/` - Business logic components
- `src/components/block/` - Page-level business units
- `src/hooks/` - Custom hooks (useMeiliClient, useCurrentInstance, etc.)
- `src/store/` - Zustand store (instances, language settings)
- `src/locales/{en,zh}/` - Translation JSON files by namespace

### Routing Structure
Routes use dynamic segments: `/ins/$insID/_layout/index/$indexUID/_layout/documents`
- `$insID` - Meilisearch instance ID
- `$indexUID` - Index unique identifier

### State Management
- **Zustand store** (`src/store/index.ts`): Manages instances list, language, warning page data
- **TanStack Query**: All Meilisearch API calls with 30s refetch interval

### i18n Namespaces
common, dashboard, task, key, upload, document, index, instance, header, sys

## Coding Standards

- Code comments in English
- Git commits in English, follow Conventional Commits (`feat(module): description`)
- File names: lowercase with hyphens, except TSX components use PascalCase
- i18n language codes: `zh-CN`, `en-US` format

## Build Configuration

- **Base path:** Configurable via `BASE_PATH` env var
- **Code splitting:** Manual chunks by node_modules package
- **Compiler:** SWC for React
- **Linting:** Biome (tab indentation, auto import sorting)

## Environment Variables

- `BASE_PATH` - Custom base path for deployment
- `SINGLETON_MODE` - Single instance mode
- `SINGLETON_HOST` - Host for singleton mode
- `SINGLETON_API_KEY` - API key for singleton mode
