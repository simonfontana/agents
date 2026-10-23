# Agents

Agent skills and instructions that encode reusable conventions and workflows.

## Skills

| Skill | Description |
|-------|-------------|
| [`agents-md`](skills/agents-md/SKILL.md) | Create and maintain `AGENTS.md` / `CLAUDE.md` files with concise, actionable agent instructions |
| [`commit-message`](skills/commit-message/SKILL.md) | Write git commit messages focused on observable behaviour change, not implementation detail |
| [`spec-review-brief`](skills/spec-review-brief/SKILL.md) | Turn an OpenSpec change into one readable brief, with Mermaid diagrams where useful, for a developer's first-pass review (unofficial, not part of OpenSpec; invoke by name) |
| [`split-commit`](skills/split-commit/SKILL.md) | Split one named commit into a series of smaller, standalone commits on a new branch |

## Instructions

| Instruction | Applies to | Description |
|-------------|------------|-------------|
| [`go-tests`](instructions/go-tests.instructions.md) | `**/*.go` | Write and review Go tests following table-driven, parallel, and mock conventions |
| [`top-down`](instructions/top-down.instructions.md) | `**` | Order functions so each call appears above the function's definition, reading top-down |

## Usage

Each **skill** lives in its own directory under `skills/` around a `SKILL.md` file with a YAML frontmatter `description` that controls when an agent automatically invokes it. The agent decides whether to load a skill. Some skills ship supporting scripts alongside it; `SKILL.md` explains when they are needed and how to set them up.

Each **instruction** is a single file under `instructions/`. Its frontmatter lists file patterns, and the tool loads the instruction whenever a matching file is in the agent's context, so the agent does not decide. The same patterns are given twice, as `applyTo` for VS Code and as `paths` for Claude Code. If no matching file is in context yet, the agent only sees the instruction's description and must choose to read it.

## Installation

### Skills

To link every skill in this repo, run the following from the repo root. Remove any names from the list that you do not want.

```sh
mkdir -p ~/.agents/skills
for skill in agents-md commit-message spec-review-brief split-commit; do
  ln -sT "$PWD/skills/$skill/" ~/.agents/skills/"$skill"
done
```

If you use Claude Code, link `~/.agents/skills/` as `~/.claude/skills/`:

```sh
ln -sT ~/.agents/skills ~/.claude/skills
```

If `~/.claude/skills/` already exists, move or merge it first, because `ln` will otherwise create the link inside it.

### Instructions

Instructions that apply to file patterns have no shared format across tools, so each tool needs its own setup.

#### VS Code (GitHub Copilot)

Link each instruction into your user prompts folder. Run from the repo root and remove any names you do not want. The path below is for Linux. If you use a non-default VS Code profile, the folder is `~/.config/Code/User/profiles/<profile-id>/prompts` instead.

```sh
mkdir -p ~/.config/Code/User/prompts
for instruction in go-tests top-down; do
  ln -sT "$PWD/instructions/$instruction.instructions.md" ~/.config/Code/User/prompts/"$instruction".instructions.md
done
```

#### Claude Code

Link each instruction into `~/.claude/rules/`. Run from the repo root and remove any names you do not want.

```sh
mkdir -p ~/.claude/rules
for instruction in go-tests top-down; do
  ln -sT "$PWD/instructions/$instruction.instructions.md" ~/.claude/rules/"$instruction".md
done
```

#### Other tools

Other tools, for example Codex, do not support instructions that apply to file patterns. You can either copy an instruction's content into the tool's global instructions file, such as `~/.codex/AGENTS.md`, so it is loaded in every session, or install it as a skill, so the agent decides when to load it. Each instruction has a `name` in its frontmatter so it also works as a skill.

To install instructions as skills, run from the repo root and remove any names you do not want:

```sh
for instruction in go-tests top-down; do
  mkdir -p ~/.agents/skills/"$instruction"
  ln -sT "$PWD/instructions/$instruction.instructions.md" ~/.agents/skills/"$instruction"/SKILL.md
done
```

### Check what is installed

To list, for each tool, what is installed from this repo, what is missing, and which links are broken, run from the repo root:

```sh
scripts/check-install.sh
```

For each missing item it prints the `ln` command that installs it. It only reads files and changes nothing. It exits with status 1 if a link is broken. Add `-a` to also list skills and instructions installed from elsewhere. Run it with `--help` for details.
