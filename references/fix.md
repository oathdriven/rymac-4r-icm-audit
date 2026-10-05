# After the report: the fix pass

The audit never fixes while it measures. Once the report is in the owner's hands, the audit
offers to fix every item on it, in rank order. On the owner's go, this is the pass.

## Before the first fix

1. **Read the list back in rank order.** All of it. The owner's go covers the list as shown.
2. **Pull out the calls only the owner can make.** Anything that spends money, deletes
   something, sends to a customer or a list, changes a price, or picks between 2 business
   choices. Ask each 1 as 1 plain question. Those fixes wait for the answer. Every other fix
   goes ahead.
3. **Follow the workspace's own rules for making changes.** If the workspace says a change to
   an app goes through a named process, a review, or a gate, each fix goes through it. The
   fix pass never steps around a gate the audit just proved.

## Each fix, 1 at a time, in rank order

1. **Make the change.** The smallest change that closes the finding. 1 fix, 1 change.
2. **Prove the change with the same test that found it.**
   - A guard that came out blind: plant the same mistake again. The guard fires now. Plant
     the clean case again. The guard stays quiet.
   - A claim that was not true: the claim now matches the thing it describes.
   - A dead route, a slot, a 2 way fact: run the script that found it. The line is gone.
   - A stuck point: the file and line the stranger named now say the thing plainly.
3. **Write 1 line in the record** under the fix: what changed, the file and line, and the
   proof (the command and its output).
4. A fix that cannot be proven is not done. Say so in the record and move on.

## After the last fix

1. **Run the 4R audit again**, all 4 layers, on a fresh scratch copy.
2. The new report shows **before and after** for every count, and every fix from this list
   marked fixed, still open (with why), or waiting on the owner's answer.
3. Anything the second run finds that the first did not goes on the new list, measured and
   ranked like the rest. Say plainly that it is new and why the first run missed it.
