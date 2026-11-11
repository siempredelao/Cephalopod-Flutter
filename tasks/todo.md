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
- [ ] 27. fix(game): show the game screen's title in full on small phones (S), before M7's screenshots

## M7: Google Play
- [ ] Crash reporting into Task 4's reporter
- [ ] Play Store screenshots made by an integration test, in both languages
- [ ] The same test plays, saves and resumes a game on a device, as the release check
