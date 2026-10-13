#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

usage() {
  cat <<'EOF'
Usage: scripts/check-install.sh [-a]

Compare the skills and instructions installed in your home folder with this
repo, one folder per tool. For anything not installed, prints the ln command
that installs it. Reads files only and changes nothing.

Options:
  -a          also list what is installed from somewhere other than this repo
  -h, --help  show this help

Marks:
  ✓  installed from this repo
  ✗  in this repo, not installed
  !  link into this repo whose target no longer exists

Exit status: 0 if no link is broken, 1 if a link is broken, 2 on wrong usage.
Folders that do not exist are skipped.
EOF
}

show_other=false
for arg in "$@"; do
  case $arg in
    -a) show_other=true ;;
    -h | --help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

repo=$(cd "$(dirname "$0")/.." && pwd -P)
problems=0

green="" red="" reset=""
if [[ -t 1 && -z ${NO_COLOR-} ]]; then
  green=$'\e[32m' red=$'\e[31m' reset=$'\e[0m'
fi

tilde() { printf '%s' "${1/#"$HOME"/\~}"; }

# Turns skills/NAME/SKILL.md or instructions/NAME.instructions.md into NAME.
item_name() {
  case $1 in
    skills/*/SKILL.md) local name=${1#skills/}; printf '%s' "${name%/SKILL.md}" ;;
    instructions/*.instructions.md) local name=${1#instructions/}; printf '%s' "${name%.instructions.md}" ;;
    *) printf '%s' "$1" ;;
  esac
}

# Usage: check LABEL DIR REPO_PATTERN SUFFIX
# SUFFIX is added to the item name to get the installed file name.
check() {
  local label=$1 dir=$2 pattern=$3 suffix=$4
  local entry file real rel name note src lines="" other="" installed=""
  printf '  %s: %s\n' "$label" "$(tilde "$dir")"
  if [[ ! -d $dir ]]; then
    echo "    not found, skipped"
    return
  fi

  for entry in "$dir"/*"$suffix"; do
    file=$entry
    [[ -d $entry ]] && file=$entry/SKILL.md
    real=$(readlink -m "$file")
    name=${entry##*/}
    if [[ $real == "$repo"/* ]]; then
      rel=${real#"$repo"/}
      if [[ -e $real ]]; then
        installed+="$rel"$'\n'
        note=""
        [[ $name != "$(item_name "$rel")$suffix" ]] && note=" (different name)"
        lines+="    $green✓$reset $name -> $rel$note"$'\n'
      else
        lines+="    ! $name -> $rel (broken link)"$'\n'
        problems=1
      fi
    elif [[ -L $entry ]]; then
      other+="      $name -> $(tilde "$(readlink "$entry")")"$'\n'
    else
      other+="      $name"$'\n'
    fi
  done

  for file in "$repo"/$pattern; do
    rel=${file#"$repo"/}
    grep -qxF "$rel" <<<"$installed" && continue
    name=$(item_name "$rel")
    src=$file
    [[ $rel == skills/* ]] && src=${file%SKILL.md}
    lines+="    $red✗$reset $name, not installed:"$'\n'
    lines+="        ln -sT $(tilde "$src") $(tilde "$dir/$name$suffix")"$'\n'
  done

  printf '%s' "$lines"
  if [[ $show_other == true && -n $other ]]; then
    printf '    Not from this repo:\n%s' "$other"
  fi
}

echo "Skills"
check "Shared" ~/.agents/skills "skills/*/SKILL.md" ""
if [[ -e ~/.claude/skills && $(readlink -m ~/.claude/skills) == "$(readlink -m ~/.agents/skills)" ]]; then
  echo "  Claude Code: ~/.claude/skills"
  echo "    link to ~/.agents/skills, see above"
else
  check "Claude Code" ~/.claude/skills "skills/*/SKILL.md" ""
fi
echo

echo "Instructions"
check "VS Code" ~/.config/Code/User/prompts "instructions/*.instructions.md" ".instructions.md"
for profile in ~/.config/Code/User/profiles/*/prompts; do
  id=${profile%/prompts}
  check "VS Code profile ${id##*/}" "$profile" "instructions/*.instructions.md" ".instructions.md"
done
check "Claude Code" ~/.claude/rules "instructions/*.instructions.md" ".md"

exit "$problems"
