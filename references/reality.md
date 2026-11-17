# Layer 3, REALITY: prove the guards, check the claims

A guard that exists is not a guard that works. A claim that says done is not a thing that is
done. Layer 3 checks both, and only in the scratch copy.

## Part A0: set the limit, then replay the saved tests

The results home keeps a folder `4r-tests/` beside the records. Every test any run planted is
on 1 list, `4r-tests/tests.tsv`, 1 test on 1 line, 7 parts with a tab between them:

`id  run  promise  kind  expect  reason  input`

- `run` is the name of the run that planted the test: the date, like `2026-11-17`, or
  `2026-11-17-2` for a 2nd run the same day.
- `kind` is mistake, clean, skip or shape. `expect` is block or pass.
- `reason` is first, new-promise, owner-hole, or legacy.
- `input` is the exact input, or the path of the file that holds it inside `4r-tests/`.

**Step 1, before anything is planted:**

`bash scripts/plant-limit.sh budget <results-home> <run> <promises>`

`<promises>` is how many promises layer 1 question 3 found. The line it prints is the most
new tests this run may save. That number is the law for the run:

| Run | New tests allowed |
|---|---|
| The first audit of a folder | up to 4 for each promise, 40 at the most |
| Every audit after the first | 0 |

If it prints `LIST THE SAVED TESTS FIRST`, an older version saved tests with no list. Write
each saved test into the list with its old run date and the reason legacy, add nothing that
was not already saved, and run budget again.

**Step 2: replay every saved test, unchanged.** **These replays are the only guard numbers
that go in "since last time".** A saved test that held last time and breaks now is a real
step back. Never rewrite a saved test to make it pass, and never remove 1. The script holds a
fingerprint of the list and fails the run if a saved line changed.

## Part A: new tests, and the only 3 times they are allowed

1. **The first audit of a folder.** Up to 4 tests for each promise.
2. **A promise that has no saved test at all**, on a later audit. Name the promise on the
   budget line with `--new-promise "the promise"`. Up to 4 tests for that promise.
3. **A hole the owner named, in the owner's own words**, in this chat or in the owner's own
   file. Pass the owner's exact words with `--owner-hole "the words"`. Up to 2 tests for each
   hole, 5 holes at the most in 1 run. The report prints those words back to the owner. An
   idea the audit had on its own is not an owner hole. Write the idea in the report as 1
   line under "a hole you could ask me to test" and plant nothing.

**A guard that changed is NOT on that list.** It does not matter who changed the guard or
why. The fix pass changes guards on every run, so "the guard changed" as a reason to plant
makes every audit bigger than the last. The replay is the test of a changed guard. A later
audit never saves more than 20 new tests in total.

For each promise that gets new tests, inside the number the budget printed:

1. **Find the guard's input.** A hook reads what the agent is about to write. A check script
   reads a file or a folder. A test reads a fixture.
2. **Plant 1 mistake the guard should catch.** Make the mistake real and specific: the
   banned word in a sentence, a price that is not on the price list, a file in the wrong
   folder, a key in a settings file. Plant the mistake in the scratch copy, or feed the
   guard a copy of its input with the mistake in it.
3. **Plant 1 clean case the guard should pass.** Almost the same input, without the
   mistake. A guard that blocks everything is as broken as a guard that blocks nothing.
4. **Spend what is left of the 4 on the shapes that matter most.** At most 2 more: a 2nd
   spelling of the mistake, or 1 case inside a skip rule in the guard (a "skip when", an
   early exit, an allow list). Pick the 2 a real person would most likely type. Never try
   to plant every shape a mistake could come in. That list has no end.
5. **Run the guard on all of them. Record 4 things:** did the guard fire on the mistake, did the
   guard stay quiet on the clean case, the exact line the guard printed, and the exit code.
6. **Save each test on the list the moment it is planted**, with this run's name and its
   reason. A test that is not on the list was not allowed.

Every skip rule found inside a guard still gets written down in the record, tested or not.
A skip nobody tested is a line in "could not see", never a reason to go over the number.

**Step 3, before the report:** `bash scripts/plant-limit.sh check <results-home> <run>`. It
must print `PLANT CHECK ... OK`. If it prints OVER THE LIMIT, take the extra tests out of the
list and out of `4r-tests/`, then run check again. No report is written on a failed check.

Use the test runner helper, `4r-replay` (`agents/4r-replay.md`, sonnet), for the replay and
the planting. If that helper is not available, set the model to sonnet on the call.

Score each guard with 1 word, and always with its count: "caught 6 of 6 planted shapes",
never the bare word. A planted mistake proves the guard catches that shape. A planted mistake
does not prove the guard catches every shape, and the report never says so:

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

**Every claim checked names its source**: where the answer was read from. "True, read off the
live page." "False, the online copy's release list." "True, 119 files counted in the folder."
A claim checked against the same note that made the claim has not been checked. Read the
answer from a different place than the place that wrote the claim.

Never check a claim by touching something live (a website form, a payment, an email). Read
only. If a claim can only be checked live, list the claim under "could not see".

## Part C: if the workspace rebuilds anything, rebuild once

If the workspace has a step that regenerates an output (a build, an export, an index), run
that step once in the scratch copy with some real work already inside. Check the real work
survived. A rebuild that deletes the owner's work is the costliest finding there is, and only
running the rebuild finds it.

## Put everything back

Every test planted this run is already on the list in the results home's `4r-tests/` (the
inputs, the expected result, and any small script that feeds them). Delete any big file a
test made, such as a fake video, and keep only what the replay needs. Then delete the scratch
copy. Nothing planted may leave the scratch.
