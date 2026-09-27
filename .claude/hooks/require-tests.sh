#!/usr/bin/env bash
# PostToolUse（Edit|Write）：編集したファイルの近くにテスト設定があれば自動で実行する。
# PostToolUse は編集を取り消せない。テストが落ちたときは exit 2 で終え、stderr の内容を Claude に渡す
# （exit 0 の stderr は Claude に届かない。公式ドキュメントの hooks の終了コードの表）。
# 合否はテストの終了コードで判定する（「fail 0」のような合格の表示を失敗と誤読しないため）。
# 使い方：プロジェクトの構成に合わせて、下の判定を書き足してよい。
input=$(cat)
file=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/' | sed 's#\\\\#/#g')
[ -z "$file" ] && exit 0
failed=""

# 変更したファイルから上の階層に向かって package.json を探し、"test" スクリプトがあれば実行する
dir=$(dirname "$file")
found=""
while [ "$dir" != "." ] && [ "$dir" != "/" ]; do
  if [ -f "$dir/package.json" ] && grep -q '"test"' "$dir/package.json" 2>/dev/null; then
    found="$dir"
    break
  fi
  dir=$(dirname "$dir")
done

if [ -n "$found" ]; then
  out=$(cd "$found" && npm test --silent 2>&1); rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "require-tests: テストが落ちています（$found、終了コード $rc）。直してから進めてください。" >&2
    printf '%s\n' "$out" | tail -15 >&2
    failed=1
  fi
fi

# node --test 形式（*.test.js）を直接編集した場合は、そのファイルだけ流す
case "$file" in
  *.test.js)
    out=$(node --test "$file" 2>&1); rc=$?
    if [ "$rc" -ne 0 ]; then
      echo "require-tests: $file が落ちています。" >&2
      printf '%s\n' "$out" | grep -E '^(not ok|ℹ fail)|Error' | head -10 >&2
      failed=1
    fi
    ;;
esac
[ -n "$failed" ] && exit 2
exit 0
