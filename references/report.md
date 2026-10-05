# Layer 4, REPORT: every finding, measured and ranked

2 outputs, every time:

1. **The record**, `templates/record.md`, saved in the results home as
   `<target-name>-<YYYY-MM-DD>.md`. If a record for this target already exists from an
   earlier date, keep that file and start the new 1 with the change since then.
   **Never write over a record.** A second audit on the same day saves as
   `<target-name>-<YYYY-MM-DD>-2.md`, a third as `-3`, and so on. The newest record is the
   "last time" for the next audit.
2. **The page**, `templates/report.html` with every `{{slot}}` filled. In Claude Code with
   Artifacts, publish the page. Anywhere else, save the page beside the record.

## Step 1. Turn every finding into a fix

Go layer by layer and list every finding. Each 1 becomes its own numbered fix. Nothing gets
merged away and nothing gets cut for length. The list has no cap.

Where findings come from:
- **Read:** every dead route, every short name an agent has to guess, every folder not on the
  map, every rule held by a sentence only, every example that breaks its rule, every unfilled
  slot in a file the agent reads, every folder with unsaved work, every key in a file, every
  fact written 2 ways.
- **Run:** every place the stranger got stuck that you checked and found true, and the job
  itself if it came out wrong or not at all.
- **Reality:** every guard that came out blind, jumpy or missing, and every claim that is no
  longer true.
- **Last time:** every fix from the last record that is still open.

## Step 2. Measure every fix

Each fix carries 3 measurements, all counted, none guessed:

| Measurement | What goes in it |
|---|---|
| **Who it hits** | customers and money, the owner's work, or the agent's way around |
| **How much** | the counted number: people on a list, files, days behind, phases, lines, times a stranger got stuck on it. Say what was counted |
| **Weight** | 1 of 4, below |

The 4 weights, heaviest first:

| Weight | Means | Examples |
|---|---|---|
| **Money** | a customer, a sale, a payment, an email to a list, a key that could leak | a guard that lets a list send through, a buyer who gets nothing, a key in a shared file |
| **Lost work** | work that could vanish or a record that lies | unsaved work, a state file behind the truth, a rebuild that deletes work |
| **Slows the agent** | the agent gets lost, guesses, or reads the wrong order | a missing route, 2 files that disagree, a rule only a reminder holds |
| **Polish** | the owner's own rules broken in small ways | a banned word, an unfilled slot, a title that breaks the voice |

## Step 3. Rank them

Heaviest weight first. Inside the same weight, the bigger counted number first. When 2 fixes
tie, the 1 the owner's own rules call hardest goes first. Number them 1 to the last.

**The most important** are every Money fix, plus any fix that hit the owner or a customer for
real in the last week. Name them at the top of the report in plain words, with why each 1
matters. If there are none, say so.

## Step 4. The completeness check, before anything is published

Count the findings in each layer of the record and count the fixes. They must match.
- Every flagged line from the 6 scripts is a fix, or is named as not a real finding with why
  (a naming example, a file in a borrowed toolkit).
- Every stuck point you checked true is a fix.
- Every guard that is not "proven" is a fix.
- Every claim that is not true is a fix.
- Every open fix from last time is on the list with its age.
If the counts do not match, the report is not done.

## The order the owner reads, top to bottom

1. **The verdict, 1 sentence.** What works, what does not, in plain words.
2. **The most important.** The fixes from step 3, each with why it matters.
3. **The counts.** Only numbers that were counted: fixes found by weight, routes that
   resolve, guards proven out of guards tested, places the stranger got stuck, keys found,
   folders unsaved, claims still true out of claims checked, open fixes from last time.
4. **Every fix, ranked.** 1 row each: the rank, the fix, who it hits, how much, the weight,
   the file and line. All of them.
5. **Layer by layer:** what Read found, what Run found (with the stranger's own words for
   each stuck point), what Reality proved (the guard table).
6. **What the audit could not see.** Always present. An empty section is a claim that the
   audit saw everything, and no audit does.
7. **The old audit you were doing, next to the 4R audit.** 1 row per finding from today:
   could an audit that only reads files have found it (finds this, sees the check exists but
   not that the check works, cannot see, not checked), and how the 4R audit found it. Name
   no person and no product. The old audit is "the old audit you were doing".
8. **Since last time**, when an earlier record exists: better, worse, same, per count, and
   every fix from last time marked fixed, still open or worse.
9. **The offer.** 1 line: "Say go and every fix gets made in this order, each with its proof,
   then the audit runs again." The calls only the owner can make are listed as plain
   questions.

## Rules for the words

- Plain English a 9th grader follows. Any technical word gets explained in the same
  sentence, the way you would to a smart friend who has never coded.
- Numbers as digits.
- A finding without a file and line, or a command and its output, does not go in.
- No score out of 100, no letter grade, no traffic light that is not backed by a count.
- End the chat summary on 1 line: "Better or worse since last time: ___, because ___." On a
  first audit: "First audit, the baseline is set."
