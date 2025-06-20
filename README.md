# Claude Setup Tool

Claude Codeプロジェクトの初期設定を自動化するツールです。

## 特徴

- **基本初期設定**: 全プロジェクトで必要な基本設定を自動構築
- **AI組織設定**: 大規模プロジェクト向けの並列処理システム
- **ユーザーフレンドリー**: 簡単なコマンドで環境構築完了

## 使い方

### ワンコマンド設定（推奨）
```bash
# 既存ディレクトリに適用
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash

# 新規プロジェクト作成
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --new-project "my-app"

# AI組織モードも含める
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --with-ai-org
```

### ローカルからの実行
```bash
# リポジトリをクローン
git clone https://github.com/daideguchi/claude-setup-tool.git
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
- プロジェクト自動分析による最適な組織構成提案
- tmuxベースの並列処理システム
- 3段階の組織構成（light/standard/full）
- インテリジェントなタスク分配システム
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

## Claude Code組織モード

### プロジェクト分析と組織構成
```bash
# プロジェクトを分析して最適な組織構成を提案
claude-org analyze

# 推奨構成で組織モードを開始
claude-org start

# カスタム構成で開始
claude-org start light    # 3名体制
claude-org start standard # 6名体制（デフォルト）
claude-org start full     # 8名体制
```

### タスク管理
```bash
# タスクの割り当て
claude-org assign frontend1 "ログイン画面の実装"

# 進捗確認
claude-org status

# 組織モード停止
claude-org stop
```

### 組織構成の詳細

#### Light構成（3名）- 小規模・アジャイル
- フルスタック開発者
- UI/UX開発者  
- DevOps

#### Standard構成（6名）- 中規模・バランス型
- アーキテクト
- フロントエンド開発者 ×2
- バックエンド開発者
- DevOps
- QA

#### Full構成（8名）- 大規模・本格的開発
- アーキテクト
- フロントエンド開発者 ×2
- バックエンド開発者 ×2
- DevOps
- QA
- データエンジニア

## 要件

### 基本設定
- Bash
- Git
- curl

### AI組織モード（オプション）
- tmux
- jq

## ライセンス

MIT