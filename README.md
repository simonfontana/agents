# Skills

A collection of agent skills that encode reusable conventions and workflows.

## Skills

| Skill | Description |
|-------|-------------|
| [`agents-md`](agents-md/SKILL.md) | Create and maintain `AGENTS.md` / `CLAUDE.md` files with concise, actionable agent instructions |
| [`commit-message`](commit-message/SKILL.md) | Write git commit messages focused on observable behaviour change, not implementation detail |
| [`go-tests`](go-tests/SKILL.md) | Write and review Go tests following table-driven, parallel, and mock conventions |
| [`spec-review-brief`](spec-review-brief/SKILL.md) | Turn a dense OpenSpec change into one readable brief that a developer can review (unofficial, not part of OpenSpec; invoke by name) |

## Usage

Each skill lives in its own directory around a `SKILL.md` file with a YAML frontmatter `description` that controls when an agent automatically invokes it. Point your agent configuration at the relevant `SKILL.md` to enable it. Some skills ship supporting scripts alongside it; `SKILL.md` explains when they are needed and how to set them up.

## Installation

To link every skill in this repo, run the following from the repo root. Remove any names from the list that you do not want.

```sh
mkdir -p ~/.agents/skills
for skill in agents-md commit-message go-tests spec-review-brief split-commit; do
  ln -sT "$PWD/$skill/" ~/.agents/skills/"$skill"
done
```

If you use Claude Code, link `~/.agents/skills/` as `~/.claude/skills/`:

```sh
ln -sT ~/.agents/skills ~/.claude/skills
```

If `~/.claude/skills/` already exists, move or merge it first, because `ln` will otherwise create the link inside it.
