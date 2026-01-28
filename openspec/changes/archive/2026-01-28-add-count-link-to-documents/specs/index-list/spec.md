# index-list Spec Delta

## ADDED Requirements

### Requirement: Count Tag Navigation to Documents

The document count tag in the index list SHALL be clickable and navigate directly to the documents page for quick access to document browsing.

#### Scenario: Click count tag to navigate to documents
- **GIVEN** a user is viewing the index list
- **WHEN** the user clicks on the count tag (showing document count)
- **THEN** the application SHALL navigate to the documents page (`/ins/$insID/index/$indexUID/documents`)
- **AND** the navigation SHALL preserve the current instance context

#### Scenario: Count tag visual feedback
- **GIVEN** a user is viewing the index list
- **WHEN** the user hovers over the count tag
- **THEN** the tag SHALL display a cursor pointer
- **AND** the tag SHALL have a visual hover state (e.g., opacity change or underline)
- **AND** a tooltip SHALL appear indicating the tag links to documents

#### Scenario: Count tag tooltip localization
- **GIVEN** a user hovers over the count tag
- **WHEN** the tooltip is displayed
- **THEN** the tooltip text SHALL be localized based on the current language setting
- **AND** English text SHALL be "View documents"
- **AND** Chinese text SHALL be "查看文档"

#### Scenario: Card header navigation unchanged
- **GIVEN** a user is viewing the index list
- **WHEN** the user clicks on the card header (index name)
- **THEN** the application SHALL navigate to the field distribution page (`/ins/$insID/index/$indexUID`)
- **AND** this behavior SHALL remain unchanged from current implementation
