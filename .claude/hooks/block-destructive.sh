#!/usr/bin/env bash
# PreToolUse（Bash）：破壊的操作・本番操作をブロックする。
# 「既定は自動で実行する。人に残すのは本人確認・規約・お金の決定・安全機構が止めた操作の4つだけ」という
# CLAUDE.md の方針にあわせて、削除・強制上書き・本番適用だけをここで止める。
input=$(cat)
if echo "$input" | grep -Eq 'git add (-A|--all|\.)( |"|$)'; then
  echo "BLOCKED: git add -A／. は使わない（意図しない変更が混ざる）。git add <パス> か git add -u で自分の変更だけを積む。" >&2
  exit 2
fi
if echo "$input" | grep -Eq 'rm -rf|git push --force|git push -f|terraform (apply|destroy)|--live'; then
  echo "BLOCKED: 破壊的／本番操作です。人が実行してください。" >&2
  exit 2
fi
exit 0
