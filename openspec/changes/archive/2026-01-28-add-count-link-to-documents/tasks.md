# Tasks

## Implementation Tasks

- [x] **1. Update IndexList component**
  - Wrap the count tag with a Link component
  - Set navigation target to documents page (`/ins/$insID/index/$indexUID/documents`)
  - Add cursor pointer and hover styles to indicate clickability

- [x] **2. Add tooltip for count tag**
  - Add tooltip to indicate clicking will navigate to documents
  - Add i18n keys for tooltip text (English and Chinese)

- [x] **3. Update localization files**
  - Add `count_tooltip` key to `src/locales/en/index.json`
  - Add `count_tooltip` key to `src/locales/zh/index.json`

- [x] **4. Update index-list spec**
  - Add new requirement for count tag navigation behavior
  - Document the expected scenarios

## Verification

- [x] Verify count tag is clickable and navigates to documents page
- [x] Verify tooltip displays correctly on hover
- [x] Verify hover state provides visual feedback
- [x] Verify card header still navigates to field distribution page
