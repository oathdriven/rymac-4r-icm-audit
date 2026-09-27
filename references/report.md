# Layer 4, REPORT

2 outputs, every time:

1. **The record**, `templates/record.md`, saved in the results home as
   `<target-name>-<YYYY-MM-DD>.md`. If a record for this target already exists from an
   earlier date, keep that file and start the new 1 with the change since then.
2. **The page**, `templates/report.html` with every `{{slot}}` filled. In Claude Code with
   Artifacts, publish the page. Anywhere else, save the page beside the record.

## The order the owner reads, top to bottom

1. **The verdict, 1 sentence.** What works, what does not, in plain words.
2. **The counts.** Only numbers that were counted: routes that resolve out of routes named,
   guards proven out of guards tested, places the stranger got stuck, keys found, folders
   unsaved, claims still true out of claims checked.
3. **The 3 fixes, ranked by what each would cost the owner if left alone.** Each fix says
   what to change, the file and line, and why the fix matters in business words: a lost
   customer, lost work, a wrong price, time.
4. **Layer by layer:** what Read found, what Run found (with the stranger's own words for
   each stuck point), what Reality proved (the guard table).
5. **What the audit could not see.** Always present. An empty section is a claim that the
   audit saw everything, and no audit does.
6. **Since last time**, when an earlier record exists: better, worse, same, per count.

## Rules for the words

- Plain English a 9th grader follows. Any technical word gets explained in the same
  sentence, the way you would to a smart friend who has never coded.
- Numbers as digits.
- A finding without a file and line, or a command and its output, does not go in.
- No score out of 100, no letter grade, no traffic light that is not backed by a count.
- End the chat summary on 1 line: "Better or worse since last time: ___, because ___." On a
  first audit: "First audit, the baseline is set."
