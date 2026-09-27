# Layer 3, REALITY: prove the guards, check the claims

A guard that exists is not a guard that works. A claim that says done is not a thing that is
done. Layer 3 checks both, and only in the scratch copy.

## Part A: plant a mistake for each promise

Take the 3 promises from layer 1, question 3. For each 1:

1. **Find the guard's input.** A hook reads what the agent is about to write. A check script
   reads a file or a folder. A test reads a fixture.
2. **Plant 1 mistake the guard should catch.** Make the mistake real and specific: the
   banned word in a sentence, a price that is not on the price list, a file in the wrong
   folder, a key in a settings file. Plant the mistake in the scratch copy, or feed the
   guard a copy of its input with the mistake in it.
3. **Plant 1 clean case the guard should pass.** Almost the same input, without the
   mistake. A guard that blocks everything is as broken as a guard that blocks nothing.
4. **Run the guard on both. Record 4 things:** did the guard fire on the mistake, did the
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

## Part B: check 3 claims that say done

Find 3 lines that claim a state: done, live, shipped, approved, passing, backed up, a count.
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

Delete the scratch copy when the report is written. Nothing planted may leave the scratch.
