# Clean up dead URLs, add joefortunepokies.win, fix NordVPN auto-fetch error

## Issues Found & Fixes

### 🗑️ Remove Dead Ignition URLs
The following URLs are returning 403, 404, or completely failing to load. They should be removed from the default rotation list:

- **ignitioncasino.net** — dead, no content returned
- **ignitionpoker.net** — dead, extremely slow, no content
- **ignitioncasino.net.lv** — dead (tied to .net domain)
- **ignitionpoker.net.lv** — dead (tied to .net domain)
- **ignitioncasino.org.lv** — returning errors
- **ignitioncasino.ltd** — returning errors
- **ignitioncasino.buzz** — returning errors
- **ignitioncasino.com** — loads a marketing/welcome page, NOT a login page — useless for login automation

### ➕ Add New Working URL
- **joefortunepokies.win/login** — confirmed working with login fields, will be added to the Joe Fortune URL rotation list (via `static.joefortunepokies.win/login`)

### 🔧 Fix NordVPN Auto-Fetch Error Spam
- Stop automatically calling `fetchPrivateKey()` on app launch — it fails with 401 every time (expired token) and pollutes the error log
- Only attempt the fetch when the user explicitly taps the button, or when a valid (non-expired) token is confirmed
- Add a check: if the token was previously marked as expired, skip the auto-fetch

### 🧹 Clean Up Stale Calibration Data
- Calibration entries with 0 successes AND 0 failures (50% default confidence) for domains that no longer exist will be auto-pruned
- Add a cleanup pass that removes calibration data for domains not in the current URL rotation list

### Summary
- **8 dead Ignition URLs removed** from defaults
- **1 new Joe Fortune URL added** (joefortunepokies.win)
- **NordVPN error spam fixed** on app launch
- **Stale calibrations cleaned up** automatically
