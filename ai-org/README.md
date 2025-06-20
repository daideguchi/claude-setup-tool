# AI組織設定

Claude Codeを使った並列タスク処理システムです。

## 概要

tmuxを使用して複数のClaude Codeインスタンスを管理し、効率的にタスクを並列処理します。

## 構成

- **マネージャー**: 1名（タスク分配と全体管理）
- **ワーカー**: 5名（タスク実行）

## ファイル構成

```
ai-org/
├── README.md              # このファイル
├── setup-ai-org.sh        # セットアップスクリプト
├── templates/
│   └── ROLES.md          # 役割定義
└── scripts/
    ├── tmux-session.sh    # tmuxセッション管理
    └── task-distributor.sh # タスク分配システム
```

## 使い方

### 1. プロジェクトへの適用

```bash
# プロジェクトディレクトリで実行
/path/to/claude-setup-tool/ai-org/setup-ai-org.sh
```

### 2. AI組織の起動

```bash
./scripts/ai-org/tmux-session.sh create
```

### 3. タスクの分配

```bash
# 対話的に入力
./scripts/ai-org/task-distributor.sh distribute

# ファイルから読み込み
./scripts/ai-org/task-distributor.sh file tasks.txt
```

## 詳細

プロジェクトに適用後、`docs/ai-org-guide.md`を参照してください。