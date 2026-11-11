/// What the About page says about the game's designer: the `copyright` line
/// of his rule sheet, his `website`, and the official `ruleSheet`.
typedef Credits = ({String copyright, Uri website, Uri ruleSheet});

/// The credits of Cephalopod, designed by Mark Steere. The copyright line is
/// his, word for word, so it stays in English in every language.
final Credits cephalopodCredits = (
  copyright: 'Copyright © February 2006 by Mark Steere',
  website: Uri.parse('https://www.marksteeregames.com'),
  ruleSheet: Uri.parse('https://www.marksteeregames.com/Cephalopod_rules.pdf'),
);
