# Layer 1, READ: 9 questions

Read the target's entry files first: the root `CLAUDE.md` (or `AGENTS.md`), then the root
`CONTEXT.md`. Then answer each question below. A question with a script gets the script's
output as its evidence. A question without a script gets a file and a line.

All scripts take the target folder and print their own evidence. Run them from the skill
folder: `bash scripts/<name>.sh <target>`.

---

## 1. Do the routes go anywhere?

`bash scripts/routes.sh <target>`

Every path the entry files name, checked on disk. The script prints `N of M resolve` and
lists each dead route with the file and line it sits on. A dead route is the cheapest hard
finding there is: the agent follows the map and lands on nothing.

## 2. Is every room on the map?

The same script's second half: every top level folder, checked for a mention in the entry
files. A folder nobody routes to is a folder the agent never opens. It is either dead weight
or work the owner thinks is covered and is not.

## 3. What holds up the biggest promise?

Find every strong rule in the entry files: the lines with always, never, only, every, must,
or refuse. List them all. Mark the ones that would cost the most if broken (money, a customer,
lost work), but test every 1 in layer 3, not only the costly ones.

Then run `bash scripts/guards.sh <target>`. The script lists everything that actually runs:
the hooks in the Claude settings files and the check scripts in the tree. For each of the 3
rules, name the guard that holds the rule, or write "held by the sentence only". A hook that
only adds a reminder and never blocks counts as a sentence.

If the script prints a `BLIND` line, the audit is running on a computer that is not the
owner's (a cloud sandbox like Cowork). Their own hooks were invisible. Write "couldn't see"
for the owner's hooks, never 0, and list it under what the audit could not see.

A rule held only by a sentence is a finding even if nobody has broken the rule yet. Layer 3
tests every guard named here.

## 4. Does an example break the rule printed beside the example?

Open every file with a worked example, a sample output, or a "for instance". Check each
example against the rules printed near the example, 1 at a time. 2 kinds show up:

- **The example contradicts the rule.** The rule says under 200 words, the sample runs 400.
- **The example leans on something that does not exist.** The sample reads
  `data/clients.csv` and there is no `data/` folder.

This is slow. This is also where the quiet findings live, because a model copies examples
before a model follows rules.

## 5. Is the owner in the workspace, or a template?

`bash scripts/placeholders.sh <target>`

Counts the unfilled slots per file: `{{slots}}`, `[YOUR ...]`, TODO, TBD, lorem ipsum,
`NOT FILLED IN`, `<PRODUCT NAME>`. A workspace full of slots makes an agent that writes like
nobody, because the owner's voice, offer and facts never made the trip in. Say which slots
sit in files the agent reads on every run.

## 6. Is any work sitting unsaved?

`bash scripts/nested-repos.sh <target>`

Finds every folder with its own save history (a git repo) inside the target. For each 1 the
script says whether the parent backup can see the folder, how many changes sit unsaved, and
how many saves never reached the online copy. A repo the parent treats as a pointer is
backed up by nobody.

## 7. Are there keys lying in files?

`bash scripts/secrets.sh <target>`

Scans every text file for the shapes of real keys (AI keys, cloud keys, payment keys,
private key blocks) and for saved settings files that usually hold keys. The script masks
every value the script prints. A key in a file is 1 shared zip away from a stranger.

## 8. Does the workspace tell 1 truth?

Check every fact the owner cares about that the entry files and status files state: every
price, every status (live, built, waiting), every count, every place a thing lives, every
date a status was written. 3 at the least. Search the tree for each 1. If the same fact is written in 2 places and the 2 disagree, the agent
will quote whichever 1 the agent read last. Cite both places. Every disagreement is its own
fix.

## 9. Is the workspace growing?

`bash scripts/size.sh <target> <last record>`

Counts the lines in the 3 parts that grow every time a fix gets added: the rules an agent
reads first (every CLAUDE.md, AGENTS.md, CONTEXT.md), the skills (the written instructions),
and the checks (every hook, guard and script). Machine built or borrowed code is set aside and
counted apart. Given the last record, each part shows its change since then.

A builder's own routine audits grew his setup from about 15,000 lines to 95,000 in a few weeks,
because every fix was added and almost nothing was deleted. An agent reads more, follows less,
and costs more every time that happens. Growth is not a crime: new work adds lines. **A part that
grew while the work stayed the same is a finding**, and so is any 1 file in the 10 biggest that
nobody can say why it is that big. The record keeps the SIZE line so the next audit can compare.

---

## What layer 1 hands to the next layers

- The 3 promises from question 3, with their guards or "sentence only". Layer 3 tests them.
- The job for layer 2: the thing the workspace exists to do, named in the workspace's own
  entry file.
