#!/usr/bin/env bash
# PreToolUse：個人情報・秘密情報が含まれる操作を拒否する（exit 2 で止める）。
input=$(cat)
patterns_file=".claude/hooks/private-patterns.txt"   # 本名・個人メール・会社名などを1行ずつ（git管理外にする）
if [ -f "$patterns_file" ]; then
  while IFS= read -r p; do
    p="${p%$'\r'}"                       # CRLF 対策
    [ -z "$p" ] && continue
    case "$p" in \#*) continue ;; esac   # # で始まる行はコメント
    if echo "$input" | grep -qiF -- "$p"; then
      echo "BLOCKED: 個人情報パターンに一致しました。仮名やブランド名に置き換えてください。" >&2
      exit 2
    fi
  done < "$patterns_file"
fi
# よくある API キー・秘密鍵の形。プレフィックスは変数で組み立てて、このファイル自体が
# スキャナの誤検知を起こさないようにしている（この分割も docs/guide.md の事故の型の一つ）。
key_prefix='sk-'"ant-"
if echo "$input" | grep -Eq "${key_prefix}|AKIA[0-9A-Z]{16}|-----BEGIN (RSA|OPENSSH) PRIVATE KEY-----"; then
  echo "BLOCKED: 秘密鍵／APIキーらしき文字列が含まれています。Secret Manager 等を使ってください。" >&2
  exit 2
fi
exit 0
