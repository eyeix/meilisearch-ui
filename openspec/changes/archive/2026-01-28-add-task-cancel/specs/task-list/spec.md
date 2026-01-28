## ADDED Requirements

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
