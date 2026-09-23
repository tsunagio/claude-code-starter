# Claude Code 業務ツール開発スターター

Claude Code で請求書処理・記事作成・集計などの業務ツールを開発・運用したい個人・小さいチーム向けの、最初の設定一式です。

## 誰向けか
- Claude Code をインストール済みで、業務まわりの自動化を任せ始めた人
- 「どこまで自動で進めてよいか」「壊れたときに誰が気づくか」を最初に決めておきたい人
- ゼロから CLAUDE.md・hooks・サブエージェントを書く時間を省きたい人

## 何が入っているか
- `CLAUDE.md` … プロジェクトの目的・絶対ルール・人に残す4つの判断・分担・進め方の雛形
- `.claude/hooks/`
  - `block-secrets.sh` … 秘密情報・個人情報らしき文字列を含む操作を止める
  - `block-destructive.sh` … 破壊的操作（`rm -rf`、force push、`terraform apply` 等）を止める
  - `require-tests.sh` … 編集の後にテストを自動実行する
  - `private-patterns.txt.example` … 個人情報パターンの書き方の例（コミットしない前提）
- `.claude/agents/` … `reviewer`（Merge前レビュー）、`researcher`（調査・要約）、`test-runner`（テスト実行）の3本
- `.claude/rules/human-turn.md` … Claude が人に判断・作業を戻すときの書式
- `.claude/settings.example.json` … 上の hooks を登録する設定例（秘密情報は含まない）
- `LICENSE` … MIT

## 5分で始める手順
1. このリポジトリをテンプレとして新しいリポジトリを作る（GitHub の「Use this template」、または中身をコピーして `git init`）。
2. `CLAUDE.md` を自分のプロジェクトの目的・絶対ルールに書き換える。
3. `.claude/settings.example.json` を `.claude/settings.json` としてコピーし、必要な hooks・permissions を有効にする。
4. `.claude/hooks/*.sh` に実行権限を付ける（`chmod +x .claude/hooks/*.sh`。Windows は Git Bash か WSL 上で実行する）。
5. `.claude/hooks/private-patterns.txt.example` を `private-patterns.txt` としてコピーし、`.gitignore` に残したまま自分の個人情報パターンを書き足す。

## 有料版・本への案内
- ここに入っているのは「そのまま置ける雛形」だけです。「なぜこの4つを人に残すのか」「hooks をどう設計するか」「実際に起きた事故の型と防ぎ方」までまとめた解説は、有料の設定パック（BOOTH、980 円）にあります：https://tsunagio.booth.pm/items/8889909
- 実例つきでもう一段深く作り込みたい場合は、Zenn の本『Claude Code×GAS で業務ツールを作る』（tsunagio、序章〜第 5 章 無料）も参考にしてください。
