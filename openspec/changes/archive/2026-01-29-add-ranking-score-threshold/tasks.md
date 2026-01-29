## 1. Schema & Type Updates

- [x] 1.1 Add `rankingScoreThreshold` to `searchPageParamsSchema` in `src/components/block/document/search/index.tsx`
- [x] 1.2 Update `SearchForm` props type to include `rankingScoreThreshold`

## 2. UI Implementation

- [x] 2.1 Add NumberInput for `rankingScoreThreshold` in `SearchForm.tsx` (next to `showRankingScore`)
- [x] 2.2 Add tooltip with explanation of the parameter

## 3. API Integration

- [x] 3.1 Add default value for `rankingScoreThreshold` in route search params
- [x] 3.2 Pass `rankingScoreThreshold` to Meilisearch API call (only when > 0)

## 4. Internationalization

- [x] 4.1 Add English translations in `src/locales/en/document.json`
- [x] 4.2 Add Chinese translations in `src/locales/zh/document.json`

## 5. Validation

- [ ] 5.1 Manual testing: verify parameter works with keyword search
- [ ] 5.2 Manual testing: verify parameter works with hybrid search
- [ ] 5.3 Verify URL params persistence works correctly
