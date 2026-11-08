# Architecture fixes: checklist by milestone

Details, acceptance criteria and files for each task are in `tasks/plan.md`.
One task is one pull request. Each needs `dart run melos run verify` green.
The numbers are the ones first planned, so they are not in order here.

## Before M5
- [ ] 1. fix(game): stop a closed game from saving the computer's move (S)
- [ ] 4. feat(app): report uncaught errors (S)
- [ ] 5. fix(game): keep playing when the game cannot be saved (S), after 4
- [ ] 6. refactor(settings): add one settings store for the whole app (M)
- [ ] 7. refactor(settings): give the settings page its own cubit (S), after 6
- [ ] 14. refactor(game): small game screen tweaks (S)
- [ ] 15. perf(game): undo two moves with one replay and one save (S)
- [ ] 17. test(engine): check that every agent runs on another isolate (S)
- [ ] Any time: 13. refactor(game): keep each screen enum conversion in one place (S)
- [ ] Any time: 16. refactor(game): read saved games with map patterns (S)
- [ ] Any time: 18. ci: use the same Flutter version as local (XS)
- [ ] Checkpoint: verify; by hand on Android: leave a game mid-search, change the theme at startup

## M5: English and Spanish (first within M5)
- [ ] 8. feat(app): set up translations (M), after 7
- [ ] 9. feat(game): translate the text mappers (M), after 8
- [ ] 10. feat(game): translate the game screen and new-game dialog (S), after 8
- [ ] 11. feat(game): translate How to play (M), after 8
- [ ] 12. test(app): check the app in Spanish (S), after 9–11
- [ ] Then the rest of M5: accessibility, palettes, animations, About, goldens last

## M6, only if the web build happens
- [ ] 2. fix(game): make the game route always show the saved game (M)
- [ ] 3. fix(game): show "thinking" before the computer searches on the web (XS)

## M7: Google Play
- [ ] Crash reporting into Task 4's reporter
- [ ] Consider a full game on a real device as a release check
