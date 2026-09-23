#!/usr/bin/env bash
# PostToolUse（Edit|Write）：編集したファイルの近くにテスト設定があれば自動で実行する。
# 失敗しても操作は止めない（PostToolUse は止められない仕組み）。結果を stderr に出して見えるようにするだけ。
# 使い方：プロジェクトの構成に合わせて、下の判定を書き足してよい。
input=$(cat)
file=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/' | sed 's#\\\\#/#g')
[ -z "$file" ] && exit 0

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
  out=$(cd "$found" && npm test --silent 2>&1 | tail -20)
  echo "require-tests: $found → $(printf '%s' "$out" | tail -3 | tr '\n' ' ')" >&2
  printf '%s' "$out" | grep -qiE 'fail|error' && echo "WARN: テストが落ちている可能性があります（$found）。出力を確認してください。" >&2
fi

# node --test 形式（*.test.js）を直接編集した場合は、そのファイルだけ流す
case "$file" in
  *.test.js)
    out=$(node --test "$file" 2>&1 | grep -E '^(ℹ| ok|not ok) ' | tr '\n' ' ')
    echo "require-tests: $file → $out" >&2
    ;;
esac
exit 0
