# Tool Risk Map

## Higher-risk Mark-XL areas

Mark-XL exposes actions for browser control, computer control, desktop interaction, file control, screen processing, app launching, messaging, and developer automation. These are useful, and also exactly where safety belongs.

## Baseline classification

| Area | Risk | Phase 02 handling |
|---|---:|---|
| Chat text response | Low | Not gated |
| Web search | Low/Medium | Not gated yet |
| Browser automation | Medium | Covered indirectly when it uses subprocess/PyAutoGUI |
| File processing read-only | Medium | Not gated yet |
| File deletion | High | Guarded |
| Desktop mouse/keyboard | High | Guarded through PyAutoGUI import hook |
| Shell commands | High/Critical | Risk-pattern guarded |
| Shutdown/system settings | Critical | Risk-pattern guarded |
| Messaging/email sending | High | Future phase approval gate |

## Recommendation

Run Jarvis through `start-safe.ps1` during all early testing. Use normal launch only when intentionally debugging the app itself.
