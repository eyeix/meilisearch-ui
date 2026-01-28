# Proposal: Add Count Link to Documents

## Summary

Make the document count tag in the index list clickable, navigating directly to the documents page instead of the field distribution page.

## Problem Statement

Currently, clicking on the index card header navigates to the field distribution page (`/ins/$insID/index/$indexUID`). Users who want to view documents must then navigate again to the documents page. This adds an extra step for a common workflow.

As described in [GitHub Issue #253](https://github.com/eyeix/meilisearch-ui/issues/253), users often want to go directly to the documents page rather than the field distribution page.

## Proposed Solution

Make the document count tag (`Count: X`) clickable and link it directly to the documents page (`/ins/$insID/index/$indexUID/documents`).

### Behavior Changes

1. **Count Tag**: The count tag showing document count will become a clickable link
2. **Navigation Target**: Clicking the count tag navigates to `/ins/$insID/index/$indexUID/documents`
3. **Visual Feedback**: The tag will have hover state to indicate it's clickable
4. **Backward Compatibility**: The card header still links to the field distribution page (no breaking change)

### User Experience

- **Before**: Click card header → Field distribution page → Navigate to documents
- **After**: Click count tag → Documents page (direct access)

## Scope

- **In Scope**: 
  - Modify `IndexList.tsx` to make count tag clickable
  - Add appropriate hover styles for the clickable tag
  - Add tooltip to indicate the tag links to documents

- **Out of Scope**:
  - Changing the card header link behavior
  - Modifying other navigation patterns

## Related

- GitHub Issue: [#253](https://github.com/eyeix/meilisearch-ui/issues/253)
- Existing Spec: `index-list` (will be modified)
