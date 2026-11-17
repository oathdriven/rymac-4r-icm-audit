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

1. **Look for a line to delete or combine before you add 1.** A stale clause gets replaced, not
   joined by a new 1. A rule written in 2 places becomes 1 place. A fix pass that only ever adds
   is how a workspace bloats: a builder's own audits took his setup from about 15,000 lines to
   95,000 that way.
2. **Make the change.** The smallest change that closes the finding. 1 fix, 1 change.
3. **Prove the change with the same test that found it.**
   - A guard that came out blind: plant the same mistake again. The guard fires now. Plant
     the clean case again. The guard stays quiet.
   - A claim that was not true: the claim now matches the thing it describes.
   - A dead route, a slot, a 2 way fact: run the script that found it. The line is gone.
   - A stuck point: the file and line the stranger named now say the thing plainly.
4. **Write 1 line in the record** under the fix: what changed, the file and line, the lines
   added and the lines removed (counted, never guessed), and the proof (the command
   and its output).
5. A fix that cannot be proven is not done. Say so in the record and move on.
6. **A fix to a guard changes the line that was blind. It does not add a new guard.** A new
   guard line is only for a step the owner cannot pull back: a send, a delete, a payment, a
   publish. A guard that stops to ask the owner about everyday work (writing over a file,
   running a script) makes the owner approve step after step, and the owner turns the guard
   off. Count the lines in each guard file before the pass and after, and put both numbers in
   the record. If a guard file grew, the chat summary says by how many lines, in its first 3
   lines.

## After the last fix

1. **Run the 4R audit again**, all 4 layers, on a fresh scratch copy. **This run plants
   nothing new.** `scripts/plant-limit.sh budget` prints 0 for it, because the fix pass
   changing a guard never earns new tests. Layer 3 replays the saved tests, the same ones
   the first run used, so before and after compare the same tests.
2. The new report shows **before and after** for every count, the size line included (run
   `scripts/size.sh` again, with the first record as the last record), and every fix from this list
   marked fixed, still open (with why), or waiting on the owner's answer.
3. Anything the second run finds in layers 1, 2 or the claims check that the first did not
   goes on the new list, measured and ranked like the rest. Say plainly that it is new and
   why the first run missed it. A new guard hole is never on that list, because no new test
   was planted.
4. **Say when to stop.** When every saved test holds and the stranger got stuck 0 times, the
   summary says: "Stop here. Every saved test holds. Running the audit again replays the
   same tests and finds nothing new. Run it again after your building changes, or name a
   hole you want tested." Never offer another fix pass on guard shapes the owner did not ask
   about.
