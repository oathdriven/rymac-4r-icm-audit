---
name: rymac-4r-icm-audit
description: Runs the 4R audit (Read, Run, Reality, Report) on an ICM workspace or any folder system an AI works from. Reads the structure, has a fresh agent with no memory do 1 real job in a throwaway copy, plants real mistakes to prove every guard catches what it claims, and writes a plain English report that lists EVERY finding, each measured and ranked by importance with file and line evidence, then fixes all of them on the owner's go and re-audits to prove each fix. Use when the user says "am I crazy", "am I crazy?", "4R audit", "audit my ICM", "audit this ICM", "run the audit", "audit day", "is my workspace drifting", "am I drifting", or asks whether a folder system, an agent folder, or an ICM workspace actually works. Make sure to use this skill whenever someone doubts their ICM setup or asks for an audit of one.
argument-hint: [target folder · blank = the workspace this session is in]
---

# The 4R audit: Read, Run, Reality, Report

A look at the files tells you what a workspace SAYS. Only running the workspace tells you
what it DOES. This audit does both, proves every guard catches what it claims to catch, and
hands the owner **every** finding in 1 report, measured and ranked. Then it fixes all of them.

**1 run finds everything it can find.** An audit that shows 3 fixes and holds the rest back
makes the owner run it again and again to find what the first run already saw. A VIP ran an
earlier version 11 times for that reason. Never again: every finding goes on the report.

Supporting files, read each 1 when its layer starts:
- `references/read.md`: layer 1, the 9 questions and the script behind each
- `references/run.md`: layer 2, the cold walk and the prompt for the fresh agent
- `references/reality.md`: layer 3, planting mistakes and checking the claims that say done
- `references/report.md`: layer 4, how every fix gets measured and ranked, and the record
- `references/fix.md`: after the report, the fix pass that fixes every item and proves it
- `templates/report.html`: the report page, fill the slots
- `templates/record.md`: the record kept in the results home

Scripts, run them, do not read them: `scripts/routes.sh`, `scripts/nested-repos.sh`,
`scripts/secrets.sh`, `scripts/placeholders.sh`, `scripts/guards.sh`, `scripts/size.sh`,
`scripts/copy-target.sh`, `scripts/examined.sh`, `scripts/verify-snapshot.sh`, `scripts/plant-limit.sh`.
`scripts/selftest.sh` proves every script on planted cases. Run the self-test first on a new machine.

## The helpers, and the model each 1 runs on

The audit has 1 boss and 3 helpers. The boss is the session the owner is talking to: the boss
reads the results, ranks the fixes and writes the report, on whatever model the owner picked.
The helpers do step by step work that a smaller model does fine, so a run never eats the
owner's usage on the biggest model.

| Helper | File | Model | Job |
|---|---|---|---|
| the script runner | `agents/4r-scripts.md` | haiku | runs the layer 1 scripts, hands back their output |
| the stranger | `agents/4r-stranger.md` | sonnet | layer 2, the cold walk |
| the test runner | `agents/4r-replay.md` | sonnet | layer 3, replays and plants tests |

Before layer 1, copy the 3 files in `agents/` into the owner's `~/.claude/agents/` folder if
they are not there (they are the audit's own files, never the target's). Start each helper by
its name. If a helper's name is not available in this session, start a general helper and
**set its model on the call** to the model in the table. A helper never runs on the boss's
model by default. The report says which model each helper ran on.

## The 4 promises this audit keeps

1. **The target is never changed during the audit.** Not 1 byte. Everything that runs,
   writes, or gets planted happens in a throwaway copy outside the target. An audit that edits
   what it measures has measured itself. Fixes come after, in the fix pass, on the owner's go.
2. **Every finding cites a file and a line, or a command and its output.** No citation, no
   finding. Unknown is an honest answer. A guess is not.
3. **No invented score.** The report gives counts that were counted and fixes measured with
   real numbers. Never a grade out of 100.
4. **Every finding is shown.** Every dead route, every unfilled slot, every unsaved folder,
   every key, every 2 way fact, every place the stranger got stuck, every guard that failed,
   every claim that is no longer true. Each 1 becomes a fix. Nothing is held for next time.

## Setup, before layer 1

1. **Target:** the folder in the arguments, else the workspace this session is in (walk up
   to the folder holding the root `CLAUDE.md`).
2. **Results home:** if the target's `CLAUDE.md` or `CONTEXT.md` names a home for 4R
   audits, use that folder and leave that folder out of every layer. Otherwise use a folder
   named `4r-audits/` beside the target, never inside the target.
3. **Scratch copy:** `bash scripts/copy-target.sh <target> <scratch>` into the session's
   temp or scratch folder. Layers 2 and 3 only ever touch the scratch copy. Every file the
   copy left out for size is printed as a `LEFT OUT` line and listed in `<scratch>-left-out.txt`.
   **The report names every 1 of them**, so the owner sees which files the stranger never saw.
   The copy step also writes the **snapshot list**, `<scratch>-snapshot.tsv`: 1 line per file
   with its fingerprint (SHA-256, a code built from the file's exact bytes), marked IN or
   LEFT OUT, and every LEFT OUT line carries its reason (over the size limit, or the git ignore
   rule that matched). Anybody can re-check the list on their own machine:
   `bash scripts/verify-snapshot.sh <folder> <scratch>-snapshot.tsv`. Run that check once on
   the copy (add the word `in`) before layer 2 and put its VERIFY line in the report.
   **A left out file the map names is NEEDED.** The copy step checks every file over the size
   limit against the entry files (CLAUDE.md, AGENTS.md, CONTEXT.md at the top). A named file up
   to a second limit (5 MB) comes along in the copy anyway and prints as `NEEDED  brought along`.
   A named file over the second limit prints as `NEEDED  NOT IN THE COPY`. That line goes at
   the top of the report, in the most important block, before anything the stranger found:
   the map sends the agent to a file the stranger never had. Read every NEEDED line before
   layer 2 starts, so a stuck point caused by the copy never gets blamed on the workspace.
4. **Last audit:** if the results home holds an earlier record for this target, read the
   record. **Every fix it listed gets checked again**: fixed, still open, or worse. An open
   fix from last time stays on this report with its age. The change since last time is the
   headline of the report.

## The layers, in order. Copy this and tick each 1 off

- [ ] **1. READ.** Answer the 9 questions in `references/read.md`. 7 of them have a script.
      Run the scripts, never answer those 7 by reading alone. Every line a script flags is a
      finding. Question 9 counts size, so the fix pass can show before and after.
- [ ] **2. RUN.** Pick 1 real job the workspace exists to do. Hand the scratch copy and the
      job to a fresh agent with the prompt in `references/run.md`. Record whether the job got
      done, how many files the agent read before knowing where to go, and every place the
      agent got stuck, each with file and line. Check each stuck point yourself. Save the
      stranger's OPENED list and run `bash scripts/examined.sh <scratch>-snapshot.tsv <opened.txt>`.
      **In the copy and opened by the auditor are 2 different claims.** The report gives both
      counts apart, and names every file the stranger went looking for that the copy left out.
- [ ] **3. REALITY.** FIRST run `bash scripts/plant-limit.sh budget <results-home> <run> <promises>`.
      The line it prints is the most new tests this run may plant. On every audit after the
      first that number is 0: replay the saved tests and plant NOTHING new. On a first audit,
      for every promise from layer 1 question 3, plant 1 mistake the guard should catch and 1
      clean case the guard should pass, in the scratch copy or on a copy of the guard's input,
      inside that number. A promise with no guard gets its mistake planted too. Then check
      **every** claim that says done, live, approved or a count in the entry files and the
      status files, 3 at the least. `references/reality.md` has the method.
- [ ] **4. REPORT.** Every finding from layers 1 to 3 becomes a numbered fix. Each fix gets
      measured (who it hits, how many, how bad) and ranked by importance, the method in
      `references/report.md`. The most important ones get named at the top. Write the record
      with `templates/record.md`, then the page with `templates/report.html`. Before the
      record is written, run `bash scripts/plant-limit.sh check <results-home> <run>`. It must
      print `PLANT CHECK ... OK`, and that line goes in the record word for word. A failed
      check means no report: take the extra tests out first. Before
      publishing, run the completeness check in `references/report.md`. Say plainly what the
      audit could not see.
- [ ] **5. FIX, on the owner's go.** Offer to fix every item, in rank order. On the go, follow
      `references/fix.md`: each fix gets its own change and its own proof, the calls only the
      owner can make get asked as plain questions, then the 4R audit runs again and the report
      shows before and after. That second run replays the saved tests and plants nothing new. Before any fix adds a line, look for a line to delete or combine.

## Rules

1. **Run the layers in order.** Layer 2 often explains a layer 1 finding, and layer 3 often
   shows a layer 1 guard never worked.
2. **A rule held only by a sentence is a finding, even when everyone obeys the rule.** A
   sentence works until the day the agent forgets the sentence. A hook that only reminds is
   still a sentence.
3. **A guard that exists is not a guard that works.** Only a planted mistake proves a guard,
   and a planted mistake proves only its own shape. The report never calls a guard proven in
   general. The report says "caught N of N planted shapes" and names the shapes (a member's AI
   made this point, v1.5.5). Every skip rule inside a guard (a "skip when", an early exit, an
   allow list) gets 1 planted case that lands inside the skip. Every claim checked names the
   source the answer was read from: the live page, the online copy, the file.
   **Every planted test is saved and replayed on every later run**, so before and after
   always compare the SAME tests. **A later audit plants 0 new tests.** New tests on a later
   run come from only 2 places: a promise that has no saved test at all, or a hole the owner
   named in the owner's own words. **A guard that changed NEVER earns new tests, no matter
   who changed it.** The replay is the test of a changed guard. This is counted by
   `scripts/plant-limit.sh`, not left to a sentence: it sets the number before layer 3 and
   checks the number before the report, and the report cannot be written over the number.
   His words, 2026-10-05: "people keep hitting me up with just ongoing fucking reports of
   new shit." A run that invents a harder test and scores it against an easier old 1 makes a
   working guard look broken, and the owner looks bad to his own people. The old wording let
   a guard "changed since the last record" earn new tests. Every fix pass changes a guard,
   so every re-audit planted more: 1 buyer's 3rd audit planted 955 mistakes (2026-11-17).
   That wording is gone.
4. **When torn between 2 readings, take the harsher 1 and say you were torn.**
5. **Write for the owner, not for a builder.** Plain words a 9th grader follows. Any
   technical word gets explained in the same sentence. Numbers as digits.
6. **Name what the audit could not see**: a folder too big to copy, a guard that needs a paid
   service, a job the workspace cannot do without a person.
7. **Sweep every file the buyer receives for his voice laws, byte for byte**: "sold" in his voice (closed, never sold), em dashes, "whole", his personal email. 2026-09-30: "This is the shape my $30,000 offer sold on." survived 4 audits of a paid zip. His words: "I THOUGHT YOU AUDITED THAT FUCKING FILE 4 TIMES?" A voice law broken in a paid file is a finding with its file and line.
8. **Never fix during the audit.** Fixes come after the report, in the fix pass, followed by
   a re-audit so each change is measured. The re-audit replays the saved tests and plants
   nothing new. When the saved tests all hold and the stranger got stuck 0 times, the report
   says so in 1 line and tells the owner to stop: running the audit again finds nothing new.
9. **Show every finding in 1 report, measured and ranked. Never only 3.** His words,
   2026-10-04: "It should show ALL things found and rank them in importance. And let them fix
   all things." and "it had my VIP running 11 fucking audits because it only found and
   reported 3 at a time." A capped list makes the owner rerun the audit to find what this run
   already saw. Every finding from every layer becomes a numbered fix with its measurements,
   its file and its line. The most important are named first. Nothing found gets held back.

## Credit

ICM, Interpretable Context Methodology, is Jake Van Clief and David McDermott's method,
https://arxiv.org/abs/2603.16021. The 4R audit is RyMac's own instrument (filesnfolders.com).
2 ideas in layer 1 come from Jake's own ICM audit, written fresh in these words: a rule that
lives only in a sentence, and an example that breaks the rule printed beside it.
