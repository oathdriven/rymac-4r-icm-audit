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

Use a fresh agent (a subagent with no shared context, or a new session). Give the agent the
prompt below with the 3 slots filled. Nothing else. No hints about where things live.

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
```

## Read what comes back

- **Done, with a file:** open the file. Check the file against the rules the workspace
  states for that kind of output. A job done wrong is worse than a job not done.
- **Files read before knowing where to go:** the entry file plus 2 more is a workspace that
  routes well. Past 5, the map is not doing its job.
- **Each stuck point** becomes a finding with the file and line the agent gave. Check the
  line yourself before it goes in the report. An agent can misread.

## If the target is too big to copy

Copy the entry files and the 1 home the job routes to, and say in the report that the walk
ran on a slice.
