# Claude Setup Tool

Claude Codeプロジェクトの初期設定を自動化するツールです。

## 🚀 クイックスタート

既存のプロジェクトディレクトリで以下のコマンドを実行するだけ：

```bash
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash
```

実行すると、以下の選択メニューが表示されます：

```
🚀 Claude Setup Tool へようこそ！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

セットアップモードを選択してください：

1) 📝 基本設定のみ
   - CLAUDE.md (ドキュメント更新システム)
   - .cursor/rules/ (Next.js 14 + TypeScript規約)
   - 基本的なプロジェクト構造

2) 🧑‍💼 AI組織設定のみ
   - プロジェクト分析システム
   - 組織構成提案（3-8名体制）
   - tmuxベースの並列処理

3) 🎯 フル設定（基本 + AI組織）
   - 上記すべての機能
   - エンタープライズ対応

4) ❌ キャンセル

選択してください [1-4]:
```

## 📋 3つのセットアップモード

### 1️⃣ 基本設定（個人開発・小規模プロジェクト向け）
Claude Codeで効率的に開発するための基本設定：
- **CLAUDE.md**: ドキュメント自動更新システム
- **コーディング規約**: Next.js 14 + TypeScript のベストプラクティス
- **プロジェクト構造**: 整理されたディレクトリ構成

### 2️⃣ AI組織設定（チーム開発向け）
複数のAIエージェントを活用した並列開発：
- **プロジェクト分析**: ファイル数・技術スタックを自動分析
- **最適な組織提案**: 3名、6名、8名の組織構成を提案
- **タスク管理**: 各メンバーへのタスク割り当てと進捗管理

### 3️⃣ フル設定（大規模プロジェクト向け）
基本設定とAI組織設定の両方を適用：
- 個人開発時は基本設定を活用
- チーム開発時はAI組織モードに切り替え
- プロジェクトの成長に合わせて柔軟に対応

## 🛠️ その他の使い方

### 自動化・CI/CD向け（非対話モード）
```bash
# 基本設定のみ
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode basic --non-interactive

# AI組織設定のみ
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode ai-org --non-interactive

# フル設定
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode full --non-interactive
```

### 新規プロジェクト作成
```bash
# 新しいディレクトリを作成してセットアップ
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --new-project "my-app" --mode full --non-interactive
```

## 🧑‍💼 AI組織モードの使い方

### ステップ1: プロジェクト分析
```bash
claude-org analyze
```
プロジェクトの規模や技術スタックを分析し、最適な組織構成を提案します。

### ステップ2: 組織モード開始
```bash
claude-org start              # 推奨構成で開始
claude-org start light        # 3名体制（小規模）
claude-org start standard     # 6名体制（中規模）
claude-org start full         # 8名体制（大規模）
```

### ステップ3: タスク管理
```bash
# タスク割り当て
claude-org assign frontend1 "ログイン画面の実装"

# 進捗確認
claude-org status

# 組織モード終了
claude-org stop
```

## 📁 作成されるファイル

```
プロジェクト/
├── CLAUDE.md              # Claude Code用の設定とルール
├── .cursor/               
│   └── rules/            # コーディング規約（5ファイル）
│       ├── coding-standards.md
│       ├── architecture.md
│       ├── patterns.md
│       ├── troubleshooting.md
│       └── dependencies.md
└── scripts/ai-org/       # AI組織モード用スクリプト（オプション）
    └── claude-org.sh
```

## ⚙️ 必要な環境

### 基本設定
- Git
- Bash
- curl

### AI組織モード（追加）
- tmux
- jq

```bash
# macOS
brew install tmux jq

# Ubuntu/Debian
sudo apt install tmux jq
```

## 📚 詳細ドキュメント

- [QUICK_START.md](QUICK_START.md) - より詳しい使い方
- [CLAUDE.md](CLAUDE.md) - ドキュメント更新システムの説明
- [AI組織設定について](ai-org/README.md) - AI組織モードの詳細

## 📄 ライセンス

MIT