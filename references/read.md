# Layer 1, READ: 8 questions

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

Find the strongest rule in the entry files: the lines with always, never, only, every, must,
or refuse. Pick the 3 that would cost the most if broken (money, a customer, lost work).

Then run `bash scripts/guards.sh <target>`. The script lists everything that actually runs:
the hooks in the Claude settings files and the check scripts in the tree. For each of the 3
rules, name the guard that holds the rule, or write "held by the sentence only".

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

Pick 3 facts the owner cares about, like a price, a status, or where a thing lives. Search
the tree for each 1. If the same fact is written in 2 places and the 2 disagree, the agent
will quote whichever 1 the agent read last. Cite both places.

---

## What layer 1 hands to the next layers

- The 3 promises from question 3, with their guards or "sentence only". Layer 3 tests them.
- The job for layer 2: the thing the workspace exists to do, named in the workspace's own
  entry file.
