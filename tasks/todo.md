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
- [ ] Checkpoint: verify; by hand on Android: leave a game mid-search, change the theme at startup

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
- [ ] 33a. feat(game): add a use case that suggests a move (S)
- [ ] 33b. refactor(game): draw a square's ring in its own widget (S)
- [ ] 33c. feat(game): let the board draw a hint (S)
- [ ] 33d. feat(game): give a hint (S)
- [ ] 37a. feat(game): say what the move just played captured, and whether it won (S)
- [ ] 34a. feat(game): draw particles (S)
- [ ] 34b. feat(game): burst a captured die (S)
- [ ] 37b. feat(game): throw confetti when the player wins (S)
- [ ] 35. feat(settings): add a Sound switch (S)
- [ ] 36a. feat(game): add audio playback (S)
- [ ] 36b. feat(game): play a sound on a capture (S)
- [ ] 36c. feat(game): play a sound when the player wins (XS)
- [ ] Checkpoint: verify; by hand on Android: first launch, hint on Hard, capture and win effects, sound off

## M7: Google Play
- [ ] L1. feat(app): get ready for more languages (S)
- [ ] L2. feat(app): translate into French, Italian and Portuguese (M)
- [ ] L3. feat(app): translate into German, Dutch, Danish, Norwegian and Swedish (M)
- [ ] L4. feat(app): translate into Polish and Turkish (S)
- [ ] Ask for a rating: the review feature, then the prompt after games, then the About link
- [ ] Crash reporting into Task 4's reporter
- [ ] feat(about): show the open-source licenses (S)
- [ ] Play Store screenshots made by an integration test, in both languages
- [ ] The same test plays, saves and resumes a game on a device, as the release check
