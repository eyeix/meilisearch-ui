# Change: Add Task Cancel Functionality

## Why

Users need the ability to cancel running or queued tasks in Meilisearch. This is particularly important for expensive operations like re-vectorization that involve external API calls (e.g., OpenAI) which are both time-consuming and costly. Currently, users have no way to stop such operations once initiated.

Reference: [GitHub Issue #254](https://github.com/eyeix/meilisearch-ui/issues/254)

## What Changes

- Add a "Cancel" button in the task list actions column for tasks with `enqueued` or `processing` status
- Implement task cancellation using Meilisearch's `POST /tasks/cancel` API endpoint
- Add confirmation dialog before canceling to prevent accidental cancellations
- Add internationalization support for cancel-related UI text (English and Chinese)
- Refresh task list after successful cancellation

## Impact

- Affected specs: `task-list`
- Affected code:
  - `src/components/block/task/List.tsx` - Add cancel button and logic
  - `src/locales/en/task.json` - Add English translations
  - `src/locales/zh/task.json` - Add Chinese translations
