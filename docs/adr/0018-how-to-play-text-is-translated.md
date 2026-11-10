# 0018. How to play's pages name a topic, and the view words it

- **Status:** Accepted
- **Date:** 2026-11-10

## Context

[ADR 0015](0015-views-render-ui-models.md) says a UI model holds meanings,
not text, with one exception: How to play. Each page's title and
explanation were English strings written next to the example board they
describe, in `presentation/bloc/`, and the page's UI model carried them as
text.

That kept the words and their example together, so one could not change
without the other being in view. But M5 translates the app
([ADR 0017](0017-translations-with-gen-l10n.md)), and the translations
reach only the view: `bloc/` has no `context` to read them from. The
tutorial would have stayed in English on a Spanish phone.

## Decision

How to play follows the rule every other screen follows. A page names what
it teaches, and the view puts it into words:

- `TutorialTopic`, an enum in `presentation/models/`, has one value per
  page: `takeTurns`, `placeAOne`, and so on.
- A tutorial step is a topic and an example board. `tutorial_steps.dart`
  holds no text.
- `TutorialTextMapper`, a text mapper in `presentation/view/`, gives each
  topic its title and its explanation, from the translation files.

The words still describe their example: "Here, 2 + 3 = 5", "Player 1 by
13 to 12". They now live in another file, so tests hold the two together:

- Every topic has a page, and the pages come in the topics' order.
- The sum and the final score in the words are the ones the example boards
  show, in every language.

This replaces the exception for How to play in ADR 0015. The rest of ADR
0015 stands.

## Consequences

- How to play speaks the language on screen, and a new language translates
  it like any other screen.
- One rule with no exception: no UI model carries finished text.
- A new page needs three things: a topic, an example, and its messages in
  every language. The compiler asks for the words, since the text mapper
  switches over every topic, and a test asks for the example.
- The words and their example are no longer side by side. The tests cover
  the numbers. Anything else the words say about the board, such as the
  dice's colours, is checked by reading.

## Alternatives considered

- **Keep the exception, and translate in the bloc folder.** The mapper
  would look up the translations by locale, and the cubit would have to
  follow the device's language. ADR 0015 rejected this for every other
  screen, for the same reasons.
- **Message keys as text** (`titleKey: 'howToPlayTakeTurnsTitle'`).
  gen-l10n generates one getter per message, not a lookup by name, so the
  view would still need a switch, without the compiler checking it covers
  every page.
- **Numbers as placeholders, filled from the example.** The words could
  never disagree with the board, but each page's UI model would carry its
  own numbers, and translators would see "{first} + {second} = {sum}"
  instead of a sentence. Two tests do the same job.
