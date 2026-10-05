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
`scripts/copy-target.sh`. `scripts/selftest.sh` proves every script on planted cases.
Run it first on a new machine.

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
   temp or scratch folder. Layers 2 and 3 only ever touch the scratch copy.
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
      agent got stuck, each with file and line. Check each stuck point yourself.
- [ ] **3. REALITY.** For **every** promise from layer 1 question 3, plant 1 mistake the guard
      should catch and 1 clean case the guard should pass, in the scratch copy or on a copy of
      the guard's input. A promise with no guard gets its mistake planted too. Then check
      **every** claim that says done, live, approved or a count in the entry files and the
      status files, 3 at the least. `references/reality.md` has the method.
- [ ] **4. REPORT.** Every finding from layers 1 to 3 becomes a numbered fix. Each fix gets
      measured (who it hits, how many, how bad) and ranked by importance, the method in
      `references/report.md`. The most important ones get named at the top. Write the record
      with `templates/record.md`, then the page with `templates/report.html`. Before
      publishing, run the completeness check in `references/report.md`. Say plainly what the
      audit could not see.
- [ ] **5. FIX, on the owner's go.** Offer to fix every item, in rank order. On the go, follow
      `references/fix.md`: each fix gets its own change and its own proof, the calls only the
      owner can make get asked as plain questions, then the 4R audit runs again and the report
      shows before and after. Before any fix adds a line, look for a line to delete or combine.

## Rules

1. **Run the layers in order.** Layer 2 often explains a layer 1 finding, and layer 3 often
   shows a layer 1 guard never worked.
2. **A rule held only by a sentence is a finding, even when everyone obeys the rule.** A
   sentence works until the day the agent forgets the sentence. A hook that only reminds is
   still a sentence.
3. **A guard that exists is not a guard that works.** Only a planted mistake proves a guard.
   Plant more than 1 shape of the mistake when the mistake comes in more than 1 shape (a send
   script with 2 different names, a word in 2 spellings).
4. **When torn between 2 readings, take the harsher 1 and say you were torn.**
5. **Write for the owner, not for a builder.** Plain words a 9th grader follows. Any
   technical word gets explained in the same sentence. Numbers as digits.
6. **Name what the audit could not see**: a folder too big to copy, a guard that needs a paid
   service, a job the workspace cannot do without a person.
7. **Never fix during the audit.** Fixes come after the report, in the fix pass, followed by
   a re-audit so each change is measured.
8. **Show every finding in 1 report, measured and ranked. Never only 3.** A capped list makes the owner rerun the audit to find what this run
   already saw. Every finding from every layer becomes a numbered fix with its measurements,
   its file and its line. The most important are named first. Nothing found gets held back.

## Credit

ICM, Interpretable Context Methodology, is Jake Van Clief and David McDermott's method,
https://arxiv.org/abs/2603.16021. The 4R audit is RyMac's own instrument (filesnfolders.com).
2 ideas in layer 1 come from Jake's own ICM audit, written fresh in these words: a rule that
lives only in a sentence, and an example that breaks the rule printed beside it.
