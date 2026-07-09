# ki-os-bridge-starter

A tiny, Git-backed exchange channel between **two AI-OS instances** that must not
share everything — for example a **personal** vault on your own machine and a
**company** AI-OS on a work machine.

Both sides drop messages for each other, pick them up, and stay in sync through a
shared rule base ([`ramp-up.md`](ramp-up.md)). The catch: one sphere may legally
**never** leak internals of the other (company confidential, or your private
health/finance data). This template ships the plumbing **and** a hard compliance
gate that enforces it — so the split is guaranteed by tooling, not just by
discipline.

> This is the public, sanitized sibling of a private setup. It contains the
> mechanism only — no messages, no real deny-list entries. Fork it, wire it to a
> **private** repo, and fill in your own guard patterns.

## Guardrail (non-negotiable)

- **Only your own, cross-sphere information.**
- **Never company internals** (product / customer / project / code / confidential).
  A leak is a compliance risk.
- **Nothing truly private** (health, finance) — the repo lives on a Git host.
- When in doubt: **don't write it.**

Enforced by the security gate (below), not by discipline alone.

## Layout

```
to-personal/{inbox,done}/     Messages FOR the personal instance
to-company/{inbox,done}/      Messages FOR the company instance
exchange-log.md               append-only ledger
ramp-up.md                    shared rule base (both instances run it)
deny-patterns.txt             generic block patterns (versioned)
deny-patterns.local.txt       sensitive patterns (LOCAL, gitignored)
scripts/guard-scan.sh         the scanner
.githooks/pre-commit          local gate
.github/workflows/guard.yml   CI gate
```

## Message format

One Markdown file per exchange, named `YYYY-MM-DD-HHMM-<slug>.md`:

```markdown
---
id: 2026-01-15-0900-<slug>
from: company            # or personal
to: personal             # or company
type: info               # info = plain drop-off · task = an instruction
status: new              # new -> done
subject: "short subject"
created: 2026-01-15T09:00
---

Body: the info, or the concrete task.

## Response (filled by the receiving side)
Result / done / follow-up question.
```

## Flow

1. **Send:** the sending side writes the file into `to-<target>/inbox/`.
2. **Receive:** the receiving side works its `to-<me>/inbox/`:
   - `type: info` → file the content into its own vault (like a capture).
   - `type: task` → do the work, write the result into `## Response`.
   - then set `status: done` and move the file to `to-<me>/done/`.
3. **Acknowledge:** on the next sync the sender checks `to-<target>/done/` for its
   own (`from: <me>`) finished items, reports them, and sets `acknowledged: true`.

One file per exchange — it travels `inbox/` → `done/`.

## Sync cycle

| Trigger      | Action |
|--------------|--------|
| session start | `git pull` → work your `inbox/` → show finished acknowledgements |
| session end   | `git add/commit/push` — pushes new/moved files (if any) |
| manual        | full sync: pull + work + push |

## Security gate (against leaking the other sphere's internals)

- **`.githooks/pre-commit`** scans staged **exchange messages** (`to-*/`,
  `exchange-log.md`) against the block patterns. A hit **hard-blocks** the commit.
  Activate: `git config core.hooksPath .githooks`.
- **`.github/workflows/guard.yml`** repeats the scan server-side on push — a net
  for machines without the hook installed.
- **Deny-list is split in two:** `deny-patterns.txt` = generic (versioned);
  `deny-patterns.local.txt` = the actually sensitive strings, **local only**,
  gitignored (so the deny-list doesn't itself reveal the internals).
- Deliberate override, only for a genuine false positive: `git commit --no-verify`.

The gate scans **only** exchange messages, never the infrastructure
(README, ramp-up, patterns, scripts, workflow).

## Setup

```bash
# 1. Fork/clone this template, then point it at YOUR OWN private repo:
git remote set-url origin git@github.com:<you>/<your-private-bridge>.git

# 2. Activate the local gate (once per clone):
git config core.hooksPath .githooks

# 3. Create your local, gitignored deny-list from the example:
cp deny-patterns.local.txt.example deny-patterns.local.txt
#    → fill in the concrete sensitive strings for THIS machine
#      (internal project names, customers, hostnames)

# 4. Both instances: read ramp-up.md and follow it.
```

**Important:** the real bridge repo should be **private**. This starter is public
on purpose — it's the mechanism, empty. Your actual channel carries content and
must not be.

New here? → run [`ramp-up.md`](ramp-up.md).

## License

MIT — see [LICENSE](LICENSE).
