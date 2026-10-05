# 4R audit: {{target name}}, {{YYYY-MM-DD}}

Target: `{{target path}}` · Scratch copy: {{files copied}} files, {{files left out}} left out
Results home: `{{results home}}` (left out of every layer) · Last audit: {{date or "none, this is the baseline"}}

## The verdict
{{1 sentence, plain words: what works and what does not}}

## The most important
{{every Money fix, plus any fix that hit the owner or a customer for real this week, each with why it matters. Or "none"}}

## The counts (each 1 counted, never estimated)
| Count | Now | Last time |
|---|---|---|
| Routes that resolve | {{n of m}} | {{or -}} |
| Top folders named in the entry files | {{n of m}} | |
| Lines with an unfilled slot, outside templates | {{n}} | |
| Folders with their own save history at risk | {{n}} | |
| Key shaped strings / settings files with keys | {{n}} / {{n}} | |
| Promises tested / guards proven | {{n}} / {{n}} | |
| Stranger's job done | {{yes, partly, no}} | |
| Files the stranger read before knowing where to go | {{n}} | |
| Places the stranger got stuck | {{n}} | |
| Claims that say done, still true | {{n of m}} | |
| Fixes found: Money / Lost work / Slows the agent / Polish | {{n}} / {{n}} / {{n}} / {{n}} | |
| Fixes from last time still open | {{n of m}} | |

## Every fix, measured and ranked (all of them, no cap)
| # | Fix | Who it hits | How much (counted) | Weight | File and line |
|---|---|---|---|---|---|
| 1 | {{fix}} | {{customers and money / the owner's work / the agent}} | {{the number, and what was counted}} | {{Money, Lost work, Slows the agent, Polish}} | `{{file}}:{{line}}` |
| {{n}} | {{every finding from every layer, 1 row each, until none is left}} | | | | |

Completeness check: {{findings counted per layer}} = {{fixes listed}}

## Waiting on the owner
{{the calls only the owner can make, each as 1 plain question}}

## Layer 1, READ
{{1 line per question, 1 to 8, each with its evidence}}

## Layer 2, RUN
Job: {{the job, in the owner's words}} · Input: {{real or made up}}
{{the stranger's report, stuck points quoted with file and line}}

## Layer 3, REALITY
| Promise | Guard | Planted mistake | Clean case | Word |
|---|---|---|---|---|
| {{promise}} | {{guard or none}} | {{fired / quiet}} | {{passed / fired}} | {{proven, blind, jumpy, missing}} |

Claims checked:
{{claim, where the claim sits, what was checked, still true or not}}

## The old audit you were doing, next to the 4R audit
| Today's finding | The old audit (reads files only) | The 4R audit |
|---|---|---|
| {{finding}} | {{finds this / sees the check exists / cannot see / not checked}} | {{how the 4R audit found it}} |

## What the audit could not see
{{always at least 1 line}}

## Since last time
{{better, worse, or same per count, or "first audit, the baseline is set"}}
{{every fix from last time: fixed, still open (with its age), or worse}}

## The fix pass
{{after the owner's go: 1 line per fix, what changed, file and line, the proof. Then the re-audit's before and after}}
