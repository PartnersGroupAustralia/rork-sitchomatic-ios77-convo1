# Code Quality Tweaks: 10 Improvements (Skip Hashable)

Implementing all recommended tweaks except #7:

### 🔴 Fixes

**1. Reuse DateFormatters instead of creating new ones**
- Replace inline `DateFormatter()` calls in FailureNotice, LoginWorkingListView, WorkingLoginsView, CredentialExportView, and ConsolidatedImportExportView with existing shared formatters

**2. Add note about hardcoded VPN keys**
- Mark the default WireGuard keys in DefaultSettingsService as placeholder/example values with a clear comment

**3. Make NoticesService observable**
- Convert NoticesService to use `@Observable` so the notices list updates in real-time in the UI

**4. Dynamic version string**
- Replace hardcoded "v10.1" in MainMenuView with the app's actual marketing version pulled from the bundle

### 🟡 Quality Tweaks

**5. Convert FailureNotice from class to struct**
- Change to a lightweight `nonisolated struct` with `Sendable` conformance

**6. Consolidate duplicate AppearanceMode enum**
- Remove the duplicate enum in PPSRAutomationViewModel and use the shared `AppAppearanceMode` from SharedTypes

**8. Increase touch targets on small menu buttons**
- Add more padding to "RECORD FLOW" and "DEBUG LOG" buttons to meet the 44pt minimum

### 🟢 Polish

**9. Add haptic feedback to Clear Notices**
- Add sensory feedback when the user taps the destructive "Clear Notices" button

**10. Use EmptyStateView in NoticesView**
- Replace the inline empty state with the reusable EmptyStateView component for visual consistency

**11. Add pull-to-refresh on Login Dashboard**
- Add `.refreshable` to LoginDashboardContentView to match the PPSR dashboard experience
