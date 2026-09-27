# The 4R Audit: Read, Run, Reality, Report

**Find out if your ICM folder system actually works, not just if the folders look right.**

Most audits read your files and tell you what the files say.

The 4R audit does that, then has a fresh AI with no memory do 1 real job in a copy of your
workspace.

Then the 4R audit plants real mistakes to see if your guards catch them.

Then you get a plain English report with the 3 fixes that matter most, each 1 with the file
and the line.

Your workspace is never changed. Not 1 byte. Everything runs in a throwaway copy.

---

## The 4 layers

1. **Read.** 8 questions about the structure. Do your routes go anywhere? Is every folder
   on the map? Is anything unsaved? Are there keys sitting in files? 6 of the 8 are
   answered by a script, not an opinion.
2. **Run.** A fresh AI that has never seen your workspace does 1 real job, cold. The AI
   reports every place it got stuck, with the file and line that caused it.
3. **Reality.** Your 3 biggest promises get tested. The audit plants a mistake each guard
   should catch and a clean case each guard should pass. Then the audit checks 3 lines
   that say "done" against the thing each 1 describes.
4. **Report.** The verdict in 1 sentence, the counts, the 3 fixes ranked by what each would
   cost you, and what the audit could not see.

No made up score out of 100. Only numbers that were counted.

---

## Install the 4R audit

1. Download **rymac-4r-icm-audit.zip** from the Releases page of this repo.
2. Unzip the zip into your Claude Code skills folder:
   - Mac or Linux: `~/.claude/skills/`
   - Windows: `C:\Users\YOUR-NAME\.claude\skills\`
   You should end up with a folder called `rymac-4r-icm-audit` inside `skills`.
3. Restart Claude Code.
4. Open Claude Code in the folder you want audited and type:

**"am I crazy?"**

That's the trigger. **"4R audit"** and **"audit my ICM"** work too.

**If the audit doesn't start:** check that the folder sits directly inside `skills`, not in a
second folder inside `skills`.

## What you need

- Claude Code
- bash, which Mac and Linux already have. On Windows, bash comes with Git for Windows.
- git and python make 2 of the checks sharper. The audit still runs without them.

## Check the audit itself first

The 4R audit tests your guards, so the audit tests its own scripts too. Run this once after
you install:

**"bash ~/.claude/skills/rymac-4r-icm-audit/scripts/selftest.sh"**

The self-test builds a workspace full of planted mistakes and a clean workspace, then checks
that every script catches the mistakes and stays quiet on the clean 1. You want to see
every line held (`34 of 34 held` on this version).

---

## Where the results go

Every audit writes a record, so the next audit can show you what changed.

- If your `CLAUDE.md` or `CONTEXT.md` names a home for 4R audits, the record goes there.
- If not, the record goes in a folder called `4r-audits` next to your workspace, never
  inside your workspace.

Run the 4R audit every week and the report tells you if you're getting better or drifting.

---

## Credit

ICM, Interpretable Context Methodology, is Jake Van Clief and David McDermott's method:
https://arxiv.org/abs/2603.16021

The 4R audit is RyMac's own instrument. 2 ideas in the Read layer come from Jake's own ICM
audit, written fresh here: a rule that lives only in a sentence, and an example that breaks
the rule printed beside the example.

Built by RyMac, USMC Veteran, at [filesnfolders.com](https://filesnfolders.com).
Come say hello in the free community: https://www.skool.com/buildmarketclose/about

MIT license: free to use, share and change.
