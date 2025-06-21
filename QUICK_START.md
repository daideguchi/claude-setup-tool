# Claude Setup Tool クイックスタート

## ワンコマンド初期設定

### インタラクティブメニュー（推奨）
```bash
# 選択メニューでセットアップ
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash
```

実行すると以下のメニューが表示されます：
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

### 非対話モード（自動化）
```bash
# 基本設定のみ
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode basic --non-interactive

# AI組織設定のみ
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode ai-org --non-interactive

# フル設定（基本 + AI組織）
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode full --non-interactive
```

### 新規プロジェクト作成
```bash
# 新しいプロジェクトを作成してフル設定
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --new-project "my-app" --mode full --non-interactive
```

## Claude Code組織モード設定

### プロジェクト分析と組織構成提案
```bash
# プロジェクトを分析して最適な組織構成を提案
claude-org analyze

# 提案例:
# 📊 プロジェクト分析結果
# ・プロジェクト規模: 中規模 (50-200ファイル)
# ・技術スタック: Next.js 14, TypeScript, Tailwind
# ・推定工数: 3-6ヶ月
# 
# 🧑‍💼 推奨組織構成 (6名体制):
# 1. アーキテクト (1名) - 技術決定、設計レビュー
# 2. フロントエンド (2名) - UI/UX、コンポーネント開発
# 3. バックエンド (1名) - API、データベース
# 4. DevOps (1名) - インフラ、CI/CD
# 5. QA (1名) - テスト、品質保証
```

### 組織モード設定コマンド
```bash
# 推奨構成で組織モードを開始
claude-org start

# カスタム構成で開始
claude-org start --config custom

# 軽量構成（3名体制）
claude-org start --light

# フル構成（8名体制）
claude-org start --full
```

### 組織モード管理コマンド
```bash
# 現在の組織状態を確認
claude-org status

# 特定のメンバーにタスクを割り当て
claude-org assign @frontend-dev1 "ログイン画面のコンポーネント作成"

# 全メンバーの進捗確認
claude-org progress

# 組織モードを終了
claude-org stop
```

## 利用シーン別コマンド

### 個人開発者・学習用
```bash
# 基本設定のみ（推奨）
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode basic --non-interactive
```

### 小規模チーム（2-3人）
```bash
# AI組織設定で軽量構成
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode ai-org --non-interactive
claude-org start light
```

### 中規模チーム（4-6人）
```bash
# フル設定で標準構成
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode full --non-interactive
claude-org start standard
```

### 大規模チーム（7人以上）
```bash
# フル設定で最大構成
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode full --non-interactive
claude-org start full
```

### 既存プロジェクトにAI組織のみ追加
```bash
# 既存のClaude Codeプロジェクトに組織機能を追加
curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash -s -- --mode ai-org --non-interactive
```

## 高度な使用方法

### 設定のカスタマイズ
```bash
# インタラクティブ設定
claude-setup configure

# 設定ファイルから読み込み
claude-setup --config ./claude-config.json
```

### 組織設定のテンプレート
```bash
# 利用可能なテンプレートを確認
claude-org templates

# 特定のテンプレートを使用
claude-org start --template "nextjs-fullstack"
claude-org start --template "react-frontend"
claude-org start --template "nodejs-backend"
```

### 進行中プロジェクトへの適用
```bash
# 既存のGitリポジトリに安全に適用
claude-setup --existing --backup

# 特定のディレクトリに適用
claude-setup --target ./my-project
```

## トラブルシューティング

### よくある問題
```bash
# 権限エラーの場合
sudo curl -fsSL https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main/scripts/quick-setup.sh | bash

# tmuxが見つからない場合（AI組織モード用）
# macOS
brew install tmux
# Ubuntu/Debian
sudo apt install tmux

# 設定の初期化
claude-setup reset
```

### ヘルプ
```bash
# 全体のヘルプ
claude-setup --help

# 組織モードのヘルプ
claude-org --help

# バージョン確認
claude-setup --version
```

## 最新版への更新
```bash
# ツール自体の更新
claude-setup update

# 設定テンプレートの更新
claude-setup update-templates
```