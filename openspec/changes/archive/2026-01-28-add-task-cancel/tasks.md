## 1. Implementation

- [x] 1.1 Add cancel-related translations to `src/locales/en/task.json`
- [x] 1.2 Add cancel-related translations to `src/locales/zh/task.json`
- [x] 1.3 Update `TaskList` component to accept `client` prop for API calls
- [x] 1.4 Add cancel button with conditional rendering (only for `enqueued`/`processing` tasks)
- [x] 1.5 Implement cancel confirmation dialog
- [x] 1.6 Implement task cancellation API call using `client.cancelTasks()`
- [x] 1.7 Add success/error toast notifications for cancel operation
- [x] 1.8 Trigger task list refresh after successful cancellation

## 2. Validation

- [x] 2.1 Verify cancel button only appears for cancelable tasks
- [x] 2.2 Verify confirmation dialog prevents accidental cancellation
- [x] 2.3 Verify task list refreshes after cancellation
- [x] 2.4 Verify translations display correctly in both languages
- [x] 2.5 Run linter to ensure no errors introduced
