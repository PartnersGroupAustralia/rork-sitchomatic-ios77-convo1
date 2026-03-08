# Full error check and targeted fixes

## URL rotation cleanup
- [x] Remove dead Ignition URLs from the default rotation list
- [x] Add `static.joefortunepokies.win/login` to the Joe Fortune rotation list

## NordVPN reliability
- [x] Stop auto-calling `fetchPrivateKey()` on app launch
- [x] Keep private-key fetching as an explicit user action from settings
- [x] Surface expired-token state without launch-time API spam

## Calibration cleanup
- [x] Auto-prune stale calibration entries that no longer match the active URL rotation list

## App Shortcuts / Spotlight hardening
- [x] Fix `AppShortcutsProvider` to use `@AppShortcutsBuilder`
- [x] Add the missing Ignition shortcut entry
- [x] Make App Intent types concurrency-safe under default `MainActor` isolation

## Verification
- [ ] Re-run a full cloud Swift build when build tooling is available in this environment
