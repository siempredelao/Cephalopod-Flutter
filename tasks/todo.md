# Architecture fixes: checklist by milestone

Details, acceptance criteria and files for each task are in `tasks/plan.md`.
One task is one pull request. Each needs `dart run melos run verify` green.
The numbers are the ones first planned, so they are not in order here.

## Before M5
- [x] 1. fix(game): stop a closed game from saving the computer's move (S)
- [x] 4. feat(app): report uncaught errors (S)
- [x] 5. fix(game): keep playing when the game cannot be saved (S), after 4
- [x] 6. refactor(settings): add one settings store for the whole app (M), with 7
- [x] 7. refactor(settings): give the settings page its own cubit (S), done in 6's PR
- [x] 14. refactor(game): small game screen tweaks (S)
- [x] 15. perf(game): undo two moves with one replay and one save (S)
- [x] 17. test(engine): check that every agent runs on another isolate (S)
- [x] Any time: 13. refactor(game): keep each screen enum conversion in one place (S)
- [x] Any time: 16. refactor(game): read saved games with map patterns (S)
- [x] Any time: 18. ci: use the same Flutter version as local (XS)
- [x] Checkpoint: verify; by hand on Android: leave a game mid-search, change the theme at startup

## M5: English and Spanish (first within M5)
- [x] 8. feat(app): set up translations (M), after 7
- [x] 9. feat(game): translate the text mappers (M), after 8
- [x] 10. feat(game): translate the game screen and new-game dialog (S), after 8
- [x] 11. feat(game): translate How to play (M), after 8
- [x] 12. test(app): check the app in Spanish (S), after 9–11
- [x] 19. feat(game): announce the game's changes to screen readers (S)
- [x] 20. test(app): check accessibility on every screen (S)
- [x] 21. feat(app): give the board a palette for each theme (M)
- [x] 22. feat(game): animate placing a die (S)
- [x] 23. feat(game): animate a capture (M), after 22
- [x] 24. feat(about): link the rule sheet and show the app's version (M)
- [x] 25. test(app): add golden images of the main screens (M), after 19–24
- [x] 26. docs: mark M5 done (XS)

## Dropped: the web build (2026-11-10)
- ~~2. fix(game): make the game route always show the saved game (M)~~
- ~~3. fix(game): show "thinking" before the computer searches on the web (XS)~~

## To fix later
- [x] 27. fix(game): show the game screen's title in full on small phones (S), done by 28

## M6: UX, in this order
- [x] 38. refactor(game): split the game screen into widgets (S)
- [x] 39. refactor(game): describe the move just played in one value (S)
- [x] 28. feat(game): move the game's actions into a menu (S), closes 27
- [x] 29. feat(game): centre How to play's dots and add Previous (S)
- [x] 30. feat(game): let the player skip How to play (XS)
- [x] 31a. feat(game): remember whether How to play was seen (S)
- [x] 31b. feat(app): show How to play the first time the app opens (S)
- [x] 32a. feat(game): count each player's dice in the game state (S)
- [x] 32b. feat(game): show how many dice each player has (S)
- [x] 33a. feat(game): add a use case that suggests a move (S)
- [x] 33b. refactor(game): draw a square's ring in its own widget (S)
- [x] 33c. feat(game): let the board draw a hint (S)
- [x] 33d-1. feat(game): show a hint in the game's state (S)
- [x] 33d-2. feat(game): say a hint aloud (S)
- [x] 33d-3. feat(game): give a hint (S)
- [x] 37a. feat(game): say what the move just played captured, and whether it won (S)
- [x] 34a. feat(game): draw particles (S)
- [x] 34b. feat(game): burst a captured die (S)
- [x] 37b. feat(game): throw confetti when the player wins (S)
- [x] 35a. feat(settings): remember whether sounds are on (S)
- [x] 35b. feat(settings): add a Sound switch (S)
- [x] 36a-1. feat(game): add the capture and win sounds (S)
- [x] 36a-2. feat(game): add audio playback (S)
- [x] 36b. feat(game): play a sound on a capture (S)
- [x] 36c. feat(game): play a sound when the player wins (XS)
- [x] Checkpoint: verify; by hand on Android: first launch, hint on Hard, capture and win effects, sound off

## M6 follow-ups, in this order
- [x] T1. test(game): one test file per use case (S)
- [x] H1. refactor(core): move the board's UI models to core (S)
- [x] H2. refactor(core): move the board's drawing to core (S)
- [x] H3. refactor(game): let the board mapper take marks, not a turn phase (S)
- [x] H4. refactor(how_to_play): make How to play a feature of its own (S–M)
- [x] HM1. feat(home): make Home clearer (S)
- [x] HM2. feat(home): show a board that plays a capture (S)
- [x] HM3. feat(game): describe the saved game for Home (S)
- [x] HM4a. feat(core): draw a board as a small picture (S)
- [x] HM4b. refactor(home): let Home hold the saved game (S)
- [x] HM4c. feat(home): word the saved game for the card (S)
- [x] HM4d. feat(home): continue from a card that shows the saved game (S)
- [x] S1. feat(game): wait longer after a bigger capture (S)
- [x] S2a. feat(core): let a square wait before its die shrinks (S)
- [x] S2b. feat(game): shrink captured dice one at a time (S)
- [x] S2c. feat(game): burst captured dice one at a time (S)
- [x] S3. feat(game): pop once per captured die (S)
- [x] Checkpoint: verify; by hand on Android: How to play on first launch and from the game, the new Home (demo board, Continue card), a 3- or 4-die capture one die at a time with a pop each

## M7: Google Play, in this order
- [x] feat(about): show the open-source licenses (S)
- [x] L1a. test(l10n): check placeholders and plurals in every language (S)
- [x] L1b. test(app): check every screen in every supported language (S)
- [x] L1c. feat(app): map Norwegian phones to Bokmål, and keep Turkish letters safe (S)
- [x] L2a. feat(app): translate into French (S)
- [x] L2b. feat(app): translate into Italian (S)
- [x] L2c. feat(app): translate into Portuguese (Brazil) (S)
- [x] L3. feat(app): translate into German, Dutch, Danish, Norwegian and Swedish (M)
- [x] L4. feat(app): translate into Polish and Turkish (S)
- [x] R1a. feat(review): ask the store for a review with in_app_review (S)
- [x] R1b. feat(review): count finished games and decide when to ask (S)
- [x] R2. feat(app): ask for a review after a finished game (S)
- [ ] R3. feat(about): add a "Rate the app" link (XS)
- [ ] I1. feat(app): use the Cephalopod icon on the launcher (S)
- [ ] I2. feat(app): show the icon on the splash screen (S)
- [ ] P1. build(android): sign release builds (S)
- [ ] E1. test(app): play, save and resume a game on a device (S)
- [ ] E2. test(app): take the store screenshots (S)
- [ ] docs: the store listing in English and Spanish (S)
- [ ] By hand in Play Console: listing, Data safety (no data collected), content rating, internal testing
- [ ] Checkpoint: verify; E1 on an emulator; a signed bundle installed from internal testing
- Not in the first release: crash reporting (decided 2026-11-12; Play Console's vitals instead)
