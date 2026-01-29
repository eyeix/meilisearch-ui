## ADDED Requirements

### Requirement: Ranking Score Threshold Filter

The document search form SHALL provide a `rankingScoreThreshold` parameter that filters out search results with ranking scores below the specified threshold.

#### Scenario: User sets ranking score threshold

- **WHEN** user enters a value between 0 and 1 in the ranking score threshold input
- **THEN** the search API call includes the `rankingScoreThreshold` parameter
- **AND** results with `_rankingScore` below the threshold are excluded

#### Scenario: Default behavior with no threshold

- **WHEN** user leaves the ranking score threshold at 0 (default)
- **THEN** the search API call does not include the `rankingScoreThreshold` parameter
- **AND** all matching results are returned regardless of score

#### Scenario: Threshold persists in URL

- **WHEN** user sets a ranking score threshold value
- **THEN** the value is persisted in the URL search parameters
- **AND** refreshing the page restores the threshold value

### Requirement: Ranking Score Threshold UI Placement

The ranking score threshold input SHALL be placed adjacent to the "Show Ranking Score" toggle in the search form, as they are functionally related parameters.

#### Scenario: UI layout consistency

- **WHEN** user views the search form
- **THEN** the ranking score threshold input appears next to the "Show Ranking Score" toggle
- **AND** both controls are visually grouped together
