# Layer 2, RUN: the cold walk

Layer 1 says what the workspace claims. Layer 2 finds out whether a stranger can use the
workspace. The stranger is a fresh agent with no memory of the owner, the auditor, or the
work.

## Pick the job

1 real job the workspace exists to do, taken from its own entry file: a row in its routing
table, or the first stage of its line. Prefer the job the owner does most. A job that ends
in a file is best, because a file can be checked.

If the job needs input (a transcript, a brief, a customer), write a small made up 1 and say
in the report that it was made up.

## Hand the job over

Use the stranger helper, `4r-stranger` (the file `agents/4r-stranger.md`, which runs on sonnet
and already carries the rules below). Hand over the 3 slots: the folder, the job, the input.
Nothing else. No hints about where things live. If that helper is not available, start a fresh
agent with no shared context, **set its model to sonnet on the call**, and give the agent the
prompt below with the 3 slots filled. A stranger on a mid size model is also the better test:
a map that only the biggest model can follow is a map that does not work.

```
You are walking a folder system cold. You have never seen it. Everything you need
must come from its own files.

The folder: <scratch copy path>

The job: <1 sentence, the way the owner would say it>
The input, if the job needs 1: <the made up input>

Rules:
- Work ONLY inside that folder. Write nothing anywhere else.
- Never fix the folder system itself. If something is broken or unclear, write it
  down as a finding and carry on the way a new person would.
- Start at the entry file (CLAUDE.md or AGENTS.md) and follow what the files say.

Report, evidence only, no advice:
1. Did the job get done? Yes, partly, or no. If a file came out, give its path.
2. How many files you read before you knew where to go.
3. Every place you got stuck or had to guess, each with the file and line that caused it.
4. Every rule you found that you could not follow, and why.
5. OPENED: every file you opened, 1 path per line, relative to the folder, in order. Add
   every file you went looking for and could not find, marked (not found).
```

## Read what comes back

- **Done, with a file:** open the file. Check the file against the rules the workspace
  states for that kind of output. A job done wrong is worse than a job not done.
- **Files read before knowing where to go:** the entry file plus 2 more is a workspace that
  routes well. Past 5, the map is not doing its job.
- **Each stuck point** becomes a finding with the file and line the agent gave. Check the
  line yourself before it goes in the report. An agent can misread.

## The examined list

Save the stranger's OPENED lines as a text file beside the copy, 1 path per line (drop the
"(not found)" marks, keep the paths). Add a second text file for the files the auditor opened
by hand while checking. Then run:

`bash scripts/examined.sh <scratch>-snapshot.tsv <stranger-opened.txt> <auditor-opened.txt>`

The script matches every path to the snapshot list and writes `<scratch>-examined.tsv`:
EXAMINED (opened, with the same fingerprint as the snapshot list), WANTED (the reader went
looking for a file the copy left out, with the reason), UNKNOWN (not on the snapshot list).
Every WANTED line gets checked: a stuck point caused by a left out file is a limit of the
copy, and the report says so instead of blaming the workspace. An opened list is the
reader's own account of what the reader opened. Say that in the report.

## If the target is too big to copy

Copy the entry files and the 1 home the job routes to, and say in the report that the walk
ran on a slice.
