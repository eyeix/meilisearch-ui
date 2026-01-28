# task-list Specification

## Purpose
This specification defines requirements for displaying the task list table in the application, including column width constraints to ensure content readability across common screen sizes.
## Requirements
### Requirement: Task List Column Layout
The task list table SHALL display all columns with appropriate widths that ensure content readability across common screen sizes, including moderately wide screens (1300px and wider).

#### Scenario: Indexes column width
- **WHEN** the task list is displayed on a screen width of approximately 1300px or wider
- **THEN** the "Indexes" column SHALL have a minimum width that prevents excessive compression
- **AND** the column SHALL display index names fully without truncation when space allows
- **AND** the column width SHALL be sufficient to read index UIDs comfortably

#### Scenario: Types column width
- **WHEN** the task list is displayed on a screen width of approximately 1300px or wider
- **THEN** the "Types" column SHALL have a minimum width that prevents excessive compression
- **AND** the column SHALL display task type labels fully without truncation when space allows
- **AND** the column width SHALL be sufficient to read localized task type names comfortably

#### Scenario: Column layout stability
- **WHEN** the task list is displayed on various screen widths (1300px, 1450px, and wider)
- **THEN** all columns SHALL maintain appropriate proportions
- **AND** the "Indexes" and "Types" columns SHALL NOT be compressed to unreadable widths
- **AND** the table layout SHALL remain stable and usable across the supported screen size range

### Requirement: Task Total Display
The task list page SHALL display the total count of tasks matching the current filter criteria.

#### Scenario: Total count display
- **WHEN** the task list page is loaded
- **THEN** the total count of tasks matching current filters SHALL be displayed
- **AND** the total SHALL be positioned between the filter section and the task table
- **AND** the total SHALL be extracted from the `total` field in the Meilisearch API response

#### Scenario: Total count updates with filters
- **WHEN** filters are applied or changed on the task list page
- **THEN** the displayed total count SHALL update to reflect the number of tasks matching the new filter criteria
- **AND** the total SHALL be recalculated from the API response

#### Scenario: Total count internationalization
- **WHEN** the task list page is displayed
- **THEN** the total count label SHALL be displayed in the user's selected language
- **AND** the label SHALL support both English and Chinese translations

### Requirement: Received Documents Column
The task list table SHALL display a "Received Documents" column showing the number of documents received for each task.

#### Scenario: Display received documents count
- **WHEN** the task list is displayed
- **AND** a task has `details.receivedDocuments` value available
- **THEN** the "Received Documents" column SHALL display the numeric count of received documents

#### Scenario: Display placeholder for unavailable data
- **WHEN** the task list is displayed
- **AND** a task does not have `details.receivedDocuments` value (e.g., index creation, settings update tasks)
- **THEN** the "Received Documents" column SHALL display "-" as a placeholder

#### Scenario: Column positioning
- **WHEN** the task list is displayed
- **THEN** the "Received Documents" column SHALL be positioned after the "Types" column
- **AND** the column SHALL have a width of 100px to accommodate numeric values

#### Scenario: Column header internationalization
- **WHEN** the task list is displayed
- **THEN** the "Received Documents" column header SHALL be displayed in the user's selected language
- **AND** the header SHALL support both English ("Received Documents") and Chinese ("接收文档数") translations

### Requirement: Task Cancellation
The task list SHALL provide the ability to cancel tasks that are in `enqueued` or `processing` status.

#### Scenario: Cancel button visibility for cancelable tasks
- **WHEN** the task list is displayed
- **AND** a task has status `enqueued` or `processing`
- **THEN** a "Cancel" button SHALL be displayed in the actions column for that task
- **AND** the button SHALL be positioned alongside the existing "Details" button

#### Scenario: Cancel button hidden for non-cancelable tasks
- **WHEN** the task list is displayed
- **AND** a task has status `succeeded`, `failed`, or `canceled`
- **THEN** the "Cancel" button SHALL NOT be displayed for that task

#### Scenario: Cancel confirmation dialog
- **WHEN** the user clicks the "Cancel" button for a task
- **THEN** a confirmation dialog SHALL be displayed
- **AND** the dialog SHALL clearly indicate the task UID being canceled
- **AND** the dialog SHALL provide "Confirm" and "Cancel" options

#### Scenario: Successful task cancellation
- **WHEN** the user confirms the cancellation in the dialog
- **THEN** the system SHALL call the Meilisearch `POST /tasks/cancel?uids={taskUid}` API
- **AND** a success notification SHALL be displayed upon successful API response
- **AND** the task list SHALL be refreshed to reflect the updated task status

#### Scenario: Failed task cancellation
- **WHEN** the user confirms the cancellation in the dialog
- **AND** the cancellation API call fails
- **THEN** an error notification SHALL be displayed with the error message
- **AND** the task list state SHALL remain unchanged

#### Scenario: Cancel button internationalization
- **WHEN** the task list is displayed
- **THEN** the "Cancel" button label SHALL be displayed in the user's selected language
- **AND** the confirmation dialog text SHALL be displayed in the user's selected language
- **AND** both English and Chinese translations SHALL be supported

