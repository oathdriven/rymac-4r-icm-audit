---
name: rymac-4r-icm-audit
description: Runs the 4R audit (Read, Run, Reality, Report) on an ICM workspace or any folder system an AI works from. Reads the structure, has a fresh agent with no memory do 1 real job in a throwaway copy, plants real mistakes to prove the guards catch them, and writes a plain English report with ranked fixes and file and line evidence. Use when the user says "am I crazy", "am I crazy?", "4R audit", "audit my ICM", "audit this ICM", "run the audit", "audit day", "is my workspace drifting", "am I drifting", or asks whether a folder system, an agent folder, or an ICM workspace actually works. Make sure to use this skill whenever someone doubts their ICM setup or asks for an audit of one.
argument-hint: [target folder · blank = the workspace this session is in]
---

# The 4R audit: Read, Run, Reality, Report

A look at the files tells you what a workspace SAYS. Only running the workspace tells you
what it DOES. This audit does both, then proves the guards catch what they claim to catch.

Supporting files, read each 1 when its layer starts:
- `references/read.md`: layer 1, the 8 questions and the script behind each
- `references/run.md`: layer 2, the cold walk and the prompt for the fresh agent
- `references/reality.md`: layer 3, planting mistakes and checking the claims that say done
- `references/report.md`: layer 4, the shape of the report and the record
- `templates/report.html`: the report page, fill the slots
- `templates/record.md`: the record kept in the results home

Scripts, run them, do not read them: `scripts/routes.sh`, `scripts/nested-repos.sh`,
`scripts/secrets.sh`, `scripts/placeholders.sh`, `scripts/guards.sh`,
`scripts/copy-target.sh`. `scripts/selftest.sh` proves every script on planted cases.
Run it first on a new machine.

## The 3 promises this audit keeps

1. **The target is never changed.** Not 1 byte. Everything that runs, writes, or gets
   planted happens in a throwaway copy outside the target. An audit that edits what it
   measures has measured itself.
2. **Every finding cites a file and a line, or a command and its output.** No citation, no
   finding. Unknown is an honest answer. A guess is not.
3. **No invented score.** The report gives counts that were counted (routes that resolve,
   guards proven, places a stranger got stuck) and ranked fixes. Never a grade out of 100.

## Setup, before layer 1

1. **Target:** the folder in the arguments, else the workspace this session is in (walk up
   to the folder holding the root `CLAUDE.md`).
2. **Results home:** if the target's `CLAUDE.md` or `CONTEXT.md` names a home for 4R
   audits, use that folder and leave that folder out of every layer. Otherwise use a folder
   named `4r-audits/` beside the target, never inside the target.
3. **Scratch copy:** `bash scripts/copy-target.sh <target> <scratch>` into the session's
   temp or scratch folder. Layers 2 and 3 only ever touch the scratch copy.
4. **Last audit:** if the results home holds an earlier record for this target, read the
   record. The change since last time is the headline of the report.

## The 4 layers, in order. Copy this and tick each 1 off

- [ ] **1. READ.** Answer the 8 questions in `references/read.md`. 6 of them have a script.
      Run the scripts, never answer those 6 by reading alone.
- [ ] **2. RUN.** Pick 1 real job the workspace exists to do. Hand the scratch copy and the
      job to a fresh agent with the prompt in `references/run.md`. Record whether the job got
      done, how many files the agent read before knowing where to go, and every place the
      agent got stuck, each with file and line.
- [ ] **3. REALITY.** For the 3 biggest promises the workspace makes, plant 1 mistake each
      guard should catch and 1 clean case the guard should pass, in the scratch copy or on a
      copy of the guard's input. Then check 3 claims that say done, live, or approved against
      the thing each claim describes. `references/reality.md` has the method.
- [ ] **4. REPORT.** Write the record into the results home with `templates/record.md`, then
      the page with `templates/report.html`. The 3 fixes are ranked by what each 1 would
      have cost the owner. Say plainly what the audit could not see.

## Rules

1. **Run the layers in order.** Layer 2 often explains a layer 1 finding, and layer 3 often
   shows a layer 1 guard never worked.
2. **A rule held only by a sentence is a finding, even when everyone obeys the rule.** A
   sentence works until the day the agent forgets the sentence.
3. **A guard that exists is not a guard that works.** Only a planted mistake proves a guard.
4. **When torn between 2 readings, take the harsher 1 and say you were torn.**
5. **Write for the owner, not for a builder.** Plain words a 9th grader follows. Any
   technical word gets explained in the same sentence. Numbers as digits.
6. **Name what the audit could not see**: a folder too big to copy, a guard that needs a paid
   service, a job the workspace cannot do without a person.
7. **Never fix during the audit.** Fixes come after the report, in their own pass, followed by
   a re-audit so the change is measured.

## Credit

ICM, Interpretable Context Methodology, is Jake Van Clief and David McDermott's method,
https://arxiv.org/abs/2603.16021. The 4R audit is RyMac's own instrument (filesnfolders.com).
2 ideas in layer 1 come from Jake's own ICM audit, written fresh in these words: a rule that
lives only in a sentence, and an example that breaks the rule printed beside it.
