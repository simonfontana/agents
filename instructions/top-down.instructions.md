---
name: top-down
description: "Top-down function order: callers above the functions they call. Use when writing, moving, or reviewing functions."
applyTo: "**"
paths:
  - "**"
---

# Top-Down Function Order

Order every file top-down: each function's definition sits below its first call. Entry points (`main`, exported functions, tests) come first.

Put a definition above its call only when the language requires it. In a script that calls `main` at the end, `main` is still the first definition and the call to `main` is the last line.
