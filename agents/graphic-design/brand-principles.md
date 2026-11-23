# Brand principles (pre-name draft)

Status: draft. Written before the name is chosen. No logo work has started.
Owner: graphic-design agent.
Source: docs/ai-pa-concept.md and agents/graphic-design/PROMPT.md.

## 1. Brand values and what they mean visually

| Value | Visual meaning |
|---|---|
| Privacy | Closed, contained shapes. Nothing leaks past the edge. No eyes, lenses or scanning motifs. |
| Calm | Generous space. Soft colour. Slow curves. One idea per mark. |
| Reliability | Even stroke weights. Stable base. Geometry on a grid. Looks the same everywhere. |
| Foresight | A quiet sense of direction or "what comes next". Suggested, never an arrow. |
| Care | Warm off-white ground. Rounded terminals. Human proportions, not machine-cold. |

- Personality: a trusted human PA. Discreet, well dressed, never loud.
- Test for every design choice: would this feel right on a 6 am flight alert?

## 2. Palette direction

Builds on the existing pastel set. Hex values are starting points. They get tuned once the name and concept are fixed.

### Pastels (existing set)
| Name | Hex | Suggested role |
|---|---|---|
| Lavender | #C9B8F0 | Lead brand candidate. Calm and private. |
| Mint | #B8E6D0 | "All clear" and confirmed states. |
| Peach | #FFD3B8 | Warmth and care. Gentle prompts. |
| Sky blue | #B8DCF5 | Travel and calendar contexts. |
| Butter yellow | #FBE9A8 | Heads-up state. Use sparingly. |
| Rose | #F5C2CF | Personal dates. Never used for errors. |

### Neutrals
| Name | Hex | Role |
|---|---|---|
| Warm off-white | #FAF7F2 | Default light background. |
| Ink | #1F1B2E | Text and single-colour logo on light. Warm, slightly violet. Not pure black. |
| Night | #15131F | Default dark background. |
| Mist | #E9E4DC | Dividers and quiet surfaces. |

### Deep partners (new)
Pastels alone fail contrast for small marks and text. Each pastel gets one deep partner.
| Pastel | Deep partner | Hex |
|---|---|---|
| Lavender | Deep violet | #4B3A8C |
| Mint | Deep green | #1F6B52 |
| Peach | Deep clay | #A1502A |
| Sky blue | Deep blue | #235E8C |
| Butter yellow | Deep ochre | #7A5C0A |
| Rose | Deep berry | #9C3554 |

### Rules
- One lead hue for the logo. The other five are supporting colours for product and marketing.
- Lavender is the current front runner. Concepts will also test mint, sky blue and peach as leads.
- Logo ratio: about 70% ground, 25% lead hue, 5% accent at most.
- Text and thin strokes use ink or a deep partner. Target WCAG AA (4.5:1) for text.
- Pastel on pastel is for large fills only. Never for text or thin lines.
- Gradients: two neighbouring pastels at most, low contrast, optional. The logo must work flat first.

## 3. Typography

- Space Grotesk: wordmark base, headlines, display sizes.
  - Weights: Medium and Bold.
  - The wordmark will be custom-adjusted and converted to outlines. No live fonts in the logo SVG.
- Inter: UI, body copy, captions, numbers.
  - Weights: Regular, Medium, SemiBold.
  - Use tabular figures for times and dates.
- Wordmark rules:
  - Lowercase or sentence case preferred. Calmer than all caps.
  - Slightly open letter spacing at small sizes.
  - At most one custom letter detail. This is where the heritage nod can live.
- Diacritics: if the name keeps a macron or accent (for example a long a), draw it as part of the mark. Also provide a plain-ASCII version.
- Both typefaces use the SIL Open Font License. Fonts are bundled locally. No font CDN calls (security gate).

## 4. Icon constraints

### At 60 px (app icon)
- One shape, one idea. Recognisable as a silhouette.
- Minimum stroke: 4 px at 60 px (about 1/15 of the icon width).
- Minimum gap between shapes: 3 px at 60 px.
- At most 2 colours plus the ground. No text. A single initial is allowed only if it is the concept.
- No gradients that the idea depends on. No fine texture.
- Design on a 1024 px grid. Keep the mark inside the central 66% so the iOS rounded mask never clips it.
- Supply a flat full-bleed square. iOS applies the corner mask.
- Plan for iOS light, dark and tinted (monochrome) icon variants.
- Test: blur it and shrink it to 29 px. It must still read.

### At billboard size
- Vector only. Curves must be clean with few anchor points. No visible kinks at 5 m wide.
- Optical corrections matter here: overshoot on round shapes, balanced joins.
- The mark must hold as a single flat colour. Print cannot rely on screen glow.
- Clear space: at least the height of the wordmark's x-height on all sides.
- Wordmark and icon must work together and apart.

### Lockups to deliver (once the name arrives)
- Icon only.
- Wordmark only.
- Horizontal lockup (icon left).
- Stacked lockup (icon above).

## 5. Light and dark rules

| Item | Light mode | Dark mode |
|---|---|---|
| Background | Warm off-white #FAF7F2 | Night #15131F |
| Single-colour logo | Ink #1F1B2E | Off-white #FAF7F2 |
| Lead hue | Pastel fill with ink or deep partner detail | Pastel becomes the glowing element on night |
| Text | Ink | Off-white at about 92% opacity |

- Never pure white (#FFFFFF) or pure black (#000000) as a background.
- Dark mode is not a simple inversion. Pastels are tuned to keep their softness. Slightly less lightness, same hue.
- No drop shadows or outlines to "rescue" the logo. If it needs rescue, the logo is wrong.
- Required versions: full colour light, full colour dark, single-colour ink, single-colour off-white.
- The single-colour version is designed first. Colour is added after.

## 6. What to avoid

- Brains, robots, sparkle stars, chat bubbles, magic wands. No "AI" clichés.
- Eyes, cameras, radar or scanning shapes. They read as surveillance.
- Padlocks and shields as the main mark. Privacy is shown by calm containment, not fear.
- Alarm bells, exclamation marks, alert red. The product is calm.
- Generic ticks, calendars and clocks as the main mark. Too common in the category.
- Tech gradients (purple to blue neon), glassmorphism, 3D gloss.
- Thin hairlines that vanish at 60 px.
- Sacred or religious symbols (Om, lotus used as decoration, laurel wreaths, Greek key borders, temple columns).
- Fake-script fonts: Latin letters styled to imitate Devanagari or Greek. This reads as costume.
- Resemblance to known assistants and their marks (Siri orb, Google dots, Alexa ring, Copilot ribbon).
- Copying any reference logo.

## 7. Heritage nod (Sanskrit, Latin or Greek)

Principle: the nod is a quiet detail found on a second look. The mark must work fully for someone who never notices it. It respects the source culture and never uses it as decoration.

### If the name is Sanskrit
- The shirorekha: the continuous headline that joins Devanagari letters. One steady horizontal line the wordmark hangs from. Also suggests "everything connected and in order".
- The bindu: a single dot as the point of focus. Could act as the "next thing" marker.
- Stroke feel: gentle modulation, as from a reed pen, on one letter only.
- Avoid: Om, mandalas, lotus clip art, faux-Devanagari Latin letters.

### If the name is Latin
- Roman inscriptional proportions: letter widths based on the square and circle, as on Trajan's column. Applied to the geometry, not as serifs everywhere.
- One small flared terminal or a single interpunct (the mid dot Romans used between words).
- A macron over a long vowel, if the name has one, drawn as a deliberate feature.
- Avoid: laurel wreaths, eagles, columns, SPQR styling, full Trajan-style caps.

### If the name is Greek
- Monoline geometry of early Greek inscriptions: even strokes, circle, triangle and square forms.
- One letter may echo its Greek ancestor (for example A and alpha, O and omicron, L and lambda) if it stays readable.
- Proportion: a simple classical ratio in the icon grid.
- Avoid: Greek key (meander) borders, temple fronts, "Greek restaurant" lettering, sigma used as E.

### Common rules for all three
- One nod only. Either in the icon or in the wordmark, not both.
- The meaning of the name should guide the concept more than the script does.
- Check the final mark with someone who reads the source script before launch.

## 8. Open items (blocked on the name)

- Final lead hue.
- Wordmark letter adjustments.
- Which heritage nod applies.
- Five concepts as set out in PROMPT.md.
