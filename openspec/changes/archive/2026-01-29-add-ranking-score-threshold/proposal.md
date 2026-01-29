# Change: Add Ranking Score Threshold to Document Search

## Why

Users performing semantic or hybrid searches often receive too many low-scoring results. The `rankingScoreThreshold` parameter in Meilisearch API (introduced in v1.3.0) allows filtering out results below a specified relevance threshold, improving search quality.

Reference: [GitHub Issue #255](https://github.com/eyeix/meilisearch-ui/issues/255)

## What Changes

- Add `rankingScoreThreshold` parameter to the search form schema
- Add UI control (NumberInput) next to the existing `showRankingScore` toggle
- Pass the parameter to Meilisearch API when value > 0
- Add i18n translations for the new field (en, zh-CN)

## Impact

- Affected specs: document-search (new capability)
- Affected code:
  - `src/components/block/document/search/index.tsx` - Schema definition
  - `src/components/biz/document/SearchForm.tsx` - UI component
  - `src/routes/ins/$insID/_layout/index/$indexUID/_layout/documents/index.tsx` - API call
  - `src/locales/en/document.json` - English translations
  - `src/locales/zh/document.json` - Chinese translations
