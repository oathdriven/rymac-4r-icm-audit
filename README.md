# The 4R Audit: Read, Run, Reality, Report

**Find out if your ICM folder system actually works, not just if the folders look right.**

Most audits read your files and tell you what the files say.

The 4R audit does that, then has a fresh AI with no memory do 1 real job in a copy of your
workspace.

Then the 4R audit plants real mistakes to see if your guards catch them.

Then you get a plain English report with **every** fix it found, not just a few. Each fix is
measured (who it hits, how much, how bad) and ranked by importance, with the file and the
line. The most important ones are named at the top.

Then, when you say go, the 4R audit fixes every item in that order, proves each fix, and runs
itself again so you see before and after.

Your workspace is never changed. Not 1 byte. Everything runs in a throwaway copy.

---

## The 4 layers

1. **Read.** 9 questions about the structure. Do your routes go anywhere? Is every folder
   on the map? Is anything unsaved, or behind its online copy? Are there keys sitting in files?
   Is the workspace growing? 7 of the 9 are answered by a script, not an opinion.
2. **Run.** A fresh AI that has never seen your workspace does 1 real job, cold. The AI
   reports every place it got stuck, with the file and line that caused it.
3. **Reality.** Every promise your workspace makes gets tested. The audit plants a mistake
   each guard should catch, in every shape the mistake comes in, and a clean case each guard
   should pass. Then the audit checks every line that says "done" or "live" against the
   thing each 1 describes.
4. **Report.** The verdict in 1 sentence, the most important fixes, the counts, then every
   fix measured and ranked, and what the audit could not see. 1 run shows everything it
   found. Nothing is held back for the next run.
5. **Fix, when you say go.** Every fix gets made in rank order, each 1 proven with the same
   test that found it. Anything that spends money, deletes something or needs your call gets
   asked as 1 plain question first. Then the 4R audit runs again.

No made up score out of 100. Only numbers that were counted.

---

## Install the 4R audit

1. Download **rymac-4r-icm-audit.zip** from the Releases section on this GitHub page.
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
every line held (`49 of 49 held` on this version).

---

## What changed in v1.5.1

A member ran the audit and caught it breaking 2 of its own promises. Both are fixed.

- **The audit never writes into your folder now, not even git's own cache.** Checking a code
  folder for unsaved work ran `git status`, which quietly rewrites `.git/index` and can leave an
  empty `index.lock` behind that stops git working there. Every git call in every script is read
  only now (`GIT_OPTIONAL_LOCKS=0`).
- **"Couldn't see" instead of "0 hooks".** Run from a cloud sandbox (Cowork, a web session), the
  audit cannot see the hooks on your own computer. It used to report 0, which tells you that you
  have no guards when you might. It now prints a `BLIND` line and the report says "couldn't see".
- Self test: 49 of 49 (the 2 new checks are these 2 bugs).

## What changed in v1.5.0

Owners running the audit kept getting a fresh list of "new" problems every run, even when
nothing in their workspace had changed. The cause was the audit, not the workspace: each run
made up harder tests and scored them against the easier tests from the run before. A guard
that worked looked broken.

- **Every planted test is saved** in your results home (`4r-tests/`) and **replayed first on
  every run, unchanged.** Before and after now compare the SAME tests.
- **New tests get planted only where something changed**: a guard file that changed since the
  last audit, a promise with no tests yet, or a hole you name. Nothing changed, nothing new.
- **New tests are counted on their own line**, never mixed into "since last time".
- The key scan no longer calls a picture packed into a web page a saved key, and still reports
  every long real token.
- Self test: 47 of 47.

## What changed in v1.4.0

A builder in the Skool asked the right question: are your fixes only added, or deleted too? His
own routine audits grew his setup from about 15,000 lines to 95,000 in a few weeks. So the 4R
audit now counts size.

- **Question 9, "Is the workspace growing?"** `scripts/size.sh` counts the lines in your rules,
  your skills and your checks, lists the 10 biggest files, sets machine built and borrowed code
  aside, and compares against your last audit.
- **The fix pass looks for a line to delete or combine before it adds 1**, and records the lines
  each fix added and removed. The re-audit shows size before and after.
- **The saved work check now asks the online copy**, so a laptop copy that fell behind its online
  copy gets flagged, not called fine.
- Self test: 47 of 47.

## What changed in v1.3.1

The key scan now finds 2 more kinds: a phone app token (Twilio), and any value saved under a name
that ends in `_TOKEN`, `_SECRET`, `_API_KEY` or `_PASSWORD`, wherever the value sits, a settings file
included. A value that names itself a test fake is counted, not listed. Self test: 39 of 39.

## What changed in v1.3.0

Earlier versions showed only the top 3 fixes. That meant running the audit again and again
to find what the first run already saw. v1.3.0 shows every finding in 1 report, measures each
1, ranks them by importance, tests every guard and every "done" line instead of 3, carries
any open fix from the last audit forward, and fixes everything on your go.

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
