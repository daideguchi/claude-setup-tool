# Claude Setup Tool

Claude Codeプロジェクトの初期設定を自動化するツールです。

## 特徴

- **基本初期設定**: 全プロジェクトで必要な基本設定を自動構築
- **AI組織設定**: 大規模プロジェクト向けの並列処理システム
- **ユーザーフレンドリー**: 簡単なコマンドで環境構築完了

## 使い方

```bash
# リポジトリをクローン
git clone <このリポジトリのURL>
cd claude-setup-tool

# 基本設定のみ
./scripts/setup.sh

# AI組織設定も含める場合
./scripts/setup.sh --with-ai-org
```

## セットアップ内容

### 基本設定
- CLAUDE.md（ドキュメント更新ルール）
- .cursor/rules/（コーディング規約等）
  - coding-standards.md
  - architecture.md
  - patterns.md
  - troubleshooting.md
  - dependencies.md
- 基本的なプロジェクト構造
- Git初期化と初回コミット

### AI組織設定（オプション）
- tmuxベースの並列処理システム
- マネージャー・ワーカー型の組織構造
- タスク分配と進捗管理システム
- リアルタイムステータス監視

## 作成されるディレクトリ構造

```
<プロジェクト名>/
├── docs/              # ドキュメント
├── src/               # ソースコード
├── tests/             # テストコード
├── scripts/           # スクリプト
├── .cursor/           # Claude Code設定
│   ├── rules/         # コーディングルール
│   └── ai-org/        # AI組織設定（オプション）
├── CLAUDE.md          # Claude Code用ルール
├── README.md          # プロジェクトREADME
└── .gitignore         # Git除外設定
```

## 要件

- Bash
- Git

## ライセンス

MIT