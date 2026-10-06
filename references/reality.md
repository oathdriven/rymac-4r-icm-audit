# Layer 3, REALITY: prove the guards, check the claims

A guard that exists is not a guard that works. A claim that says done is not a thing that is
done. Layer 3 checks both, and only in the scratch copy.

## Part A0: replay the saved tests first

The results home keeps a folder `4r-tests/` beside the records: every mistake and clean case
any earlier run planted, each with the guard it feeds, the exact input, and what the guard
should do (block or pass). Replay every 1 of them first, unchanged. **These replays are the
only guard numbers that go in "since last time".** A saved test that held last time and
breaks now is a real step back. Never rewrite a saved test to make it pass.

## Part A: plant new shapes, only where something changed

Plant new tests only for: a promise with no saved tests yet, a guard file changed since the
last record (its date or its save history says so), or a hole the owner named. Nothing
changed means nothing new gets planted, and the replay is the answer. Every new test gets
saved into `4r-tests/` the same run, and the report lists new tests in their own count,
apart from the replays. For each promise that gets new tests:

1. **Find the guard's input.** A hook reads what the agent is about to write. A check script
   reads a file or a folder. A test reads a fixture.
2. **Plant 1 mistake the guard should catch.** Make the mistake real and specific: the
   banned word in a sentence, a price that is not on the price list, a file in the wrong
   folder, a key in a settings file. Plant the mistake in the scratch copy, or feed the
   guard a copy of its input with the mistake in it.
3. **Plant 1 clean case the guard should pass.** Almost the same input, without the
   mistake. A guard that blocks everything is as broken as a guard that blocks nothing.
4. **Plant every shape the mistake comes in.** A send script can have 2 names. A banned word
   can have 2 spellings. A guard that catches 1 shape and misses the other is blind, and only
   planting both shows it.
5. **Run the guard on all of them. Record 4 things:** did the guard fire on the mistake, did the
   guard stay quiet on the clean case, the exact line the guard printed, and the exit code.

Score each guard with 1 word:

| Word | Means |
|---|---|
| **proven** | fired on the mistake, passed the clean case |
| **blind** | stayed quiet on the mistake |
| **jumpy** | fired on the clean case too |
| **missing** | the promise has no guard at all (from layer 1) |

For a promise with no guard, plant the mistake anyway and show that nothing stops the
mistake. That turns "sentence only" from an opinion into evidence.

## Part B: check every claim that says done

Find every line in the entry files and the status files that claims a state, 3 at the least: done, live, shipped, approved, passing, backed up, a count.
Status files, trackers and handoff notes are full of them. For each 1, check the thing the
claim describes:

- a file said to exist: does the file exist?
- a count: count again.
- a check said to pass: run the check.
- a date: is the thing older or newer than the claim?

A claim that was true once and is not true now is the most common kind of wrong in a
workspace, because nobody re-reads a line that says done.

Never check a claim by touching something live (a website form, a payment, an email). Read
only. If a claim can only be checked live, list the claim under "could not see".

## Part C: if the workspace rebuilds anything, rebuild once

If the workspace has a step that regenerates an output (a build, an export, an index), run
that step once in the scratch copy with some real work already inside. Check the real work
survived. A rebuild that deletes the owner's work is the costliest finding there is, and only
running the rebuild finds it.

## Put everything back

Save every test planted this run into the results home's `4r-tests/` (the inputs, the
expected result, and any small script that feeds them). Then delete the scratch copy. Nothing planted may leave the scratch.
