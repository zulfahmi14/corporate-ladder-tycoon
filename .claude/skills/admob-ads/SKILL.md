---
name: admob-ads
description: AdMob integration rules for this game - rewarded and interstitial placements, frequency caps, test IDs vs real IDs, UMP consent (GDPR/Japan APPI), no-fill handling, policy compliance. Use for any ads code, ad IDs, consent, or app-ads.txt work.
---

# AdMob ads

## Placements (product rules, approved in handoff)
| Type | Trigger | Reward / rule |
| --- | --- | --- |
| Rewarded | "2x income" button | 2x all income for 30 min; stacking extends up to 2 h max |
| Rewarded | Overtime boost | refill stamina / extra overtime multiplier (value in the design doc) |
| Rewarded | Offline return popup | doubles offline earnings for that return |
| Interstitial | After a promotion screen is dismissed | only if >= 5 min since last interstitial AND player has played >= 10 min total AND not within 3 min of a rewarded ad |
| Banner | none | never |

- Rewarded ads are always optional, clearly labeled, and the reward is given
  only in the `on_user_earned_reward` callback.
- Never show an ad on app start, on resume, during a tap, or right after a
  button press the player did not intend for an ad.
- No-fill / offline: hide the ad button (do not show a broken button); the
  game is fully playable with zero ads.
- Ads live behind one `Ads` autoload with a fake implementation for desktop
  and tests; game code never calls the plugin directly.

## IDs
- Debug builds: Google's official **test** ad unit IDs only. Never click
  real ads during testing (account ban risk).
- Release: real app ID + unit IDs in `config/ads_release.cfg` selected by the
  export feature tag; IDs are not secret but stay out of debug builds.
- Register owner's phone as a test device.

## Consent and privacy
- Use the UMP SDK (via the plugin) to show the consent form where required
  (EEA/UK/CH) before requesting ads; respect the result.
- Japan APPI: disclose ad SDK data use in the privacy policy.
- Do not target children: target audience 13+, set
  `tag_for_child_directed_treatment = false`, max ad content rating `T`.
- `app-ads.txt` on the developer website root (GitHub Pages).

## Plugin
Pinned Godot 4 Android AdMob plugin (see dependency-security; candidate in
Master Plan Facts). Review its manifest permissions before adding.
