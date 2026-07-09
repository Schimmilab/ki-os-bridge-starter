# Bridge Ramp-Up (shared rule base)

> Both AI-OS instances run this so they behave identically ("one AI-OS, not two").
> Change something here → both pull it on the next sync.

## If you are an AI-OS instance using this bridge:

1. **Repo location:** a **private** repo (e.g. `<you>/<your-bridge>`), cloned to a
   local working directory. Both machines access it through the same account/org.

2. **Activate the gate (once, after cloning):**
   - `git config core.hooksPath .githooks`
   - create `deny-patterns.local.txt` (gitignored) with the concretely sensitive
     internal strings of *this* machine (internal project names, customers, hostnames).

3. **Guardrail (hard):** only the user's own, cross-sphere info enters the bridge.
   Never company internals. Never truly-private data (health/finance).
   When in doubt: don't write it.

4. **Receive (on session start):** work `to-<me>/inbox/` —
   `info` → file into your own vault; `task` → execute + fill `## Response`;
   then set `status: done` and move the file to `to-<me>/done/`.

5. **Send:** write a file into `to-<other>/inbox/` (format in the README).

6. **Acknowledge (on session start):** check `to-<other>/done/` for your own finished
   items, report them, set `acknowledged: true`.

7. **Sync:** session start = pull, session end = push, manual trigger = both.

8. **`<me>`** is `personal` on the personal machine, `company` on the work machine.

9. **Auto-routing:** if the user signals that some data is meant for the OTHER
   instance ("put this over there", "I'll need this on the other side"), write it
   automatically as a bridge message into `to-<other>/inbox/`, append to the log,
   and push — no confirmation needed. The guardrail still holds: only the user's own
   info, never company internals. Distinction: plain job *context* stays in your own
   vault; only genuine hand-over intent goes into the bridge.
