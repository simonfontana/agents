---
name: top-down
description: Top-down function order. Use when writing, moving, or reviewing functions.
applyTo: "**"
paths:
  - "**"
---

Order functions top-down: each definition sits below its first call, and entry points (`main`, exported functions, tests) come first. Put a definition above its call only when the language requires it. In a script, define `main` first and call it on the last line.

Apply this order only to functions you add or move. Leave existing functions where they are, even when out of order.
