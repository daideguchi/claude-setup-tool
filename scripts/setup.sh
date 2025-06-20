#!/bin/bash

# Claude Code 初期設定スクリプト
# 使用方法: ./setup.sh [--with-ai-org]

set -e

# 色付きの出力用関数
print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# AI組織設定フラグのチェック
WITH_AI_ORG=false
if [[ "$1" == "--with-ai-org" ]]; then
    WITH_AI_ORG=true
fi

# プロジェクトルートの取得
PROJECT_ROOT=$(pwd)
print_info "プロジェクトルート: $PROJECT_ROOT"

# 初期設定開始
print_info "Claude Code 初期設定を開始します..."

# 1. プロジェクト名の入力
read -p "プロジェクト名を入力してください: " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
    print_error "プロジェクト名が入力されていません"
    exit 1
fi

# 2. 新しいプロジェクトディレクトリの作成
PROJECT_DIR="$PROJECT_ROOT/$PROJECT_NAME"
if [[ -d "$PROJECT_DIR" ]]; then
    print_error "ディレクトリ '$PROJECT_NAME' は既に存在します"
    exit 1
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
print_success "プロジェクトディレクトリを作成しました: $PROJECT_DIR"

# 3. 必要なディレクトリ構造の作成
print_info "ディレクトリ構造を作成中..."
mkdir -p {docs,.cursor/rules,src,tests,scripts}

# 4. CLAUDE.mdファイルのコピーと更新
print_info "CLAUDE.mdを設定中..."
cp "$PROJECT_ROOT/claude-setup-tool/CLAUDE.md" ./CLAUDE.md
echo "" >> ./CLAUDE.md
echo "## プロジェクト情報" >> ./CLAUDE.md
echo "- プロジェクト名: $PROJECT_NAME" >> ./CLAUDE.md
echo "- 作成日: $(date +%Y-%m-%d)" >> ./CLAUDE.md
echo "- 初期設定: 基本設定$([ "$WITH_AI_ORG" == "true" ] && echo " + AI組織設定")" >> ./CLAUDE.md

# 5. .cursor/rulesディレクトリのコピー
print_info ".cursor/rulesを設定中..."
cp -r "$PROJECT_ROOT/claude-setup-tool/.cursor/rules/"* ./.cursor/rules/

# 6. 基本的なドキュメントの作成
print_info "基本ドキュメントを作成中..."

# README.mdの作成
cat > README.md << EOF
# $PROJECT_NAME

## 概要
このプロジェクトはClaude Codeを使用して初期設定されました。

## セットアップ
\`\`\`bash
# 依存関係のインストール
# npm install または pip install -r requirements.txt

# 開発環境の起動
# npm run dev または python main.py
\`\`\`

## ディレクトリ構造
\`\`\`
$PROJECT_NAME/
├── docs/          # ドキュメント
├── src/           # ソースコード
├── tests/         # テストコード
├── scripts/       # スクリプト
├── .cursor/       # Claude Code設定
│   └── rules/     # コーディングルール
└── CLAUDE.md      # Claude Code用ルール
\`\`\`

## 開発ガイドライン
CLAUDE.mdおよび.cursor/rules/配下のドキュメントを参照してください。
EOF

# .gitignoreの作成
cat > .gitignore << EOF
# 依存関係
node_modules/
venv/
.venv/
__pycache__/
*.pyc

# ビルド成果物
dist/
build/
*.egg-info/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# 環境変数
.env
.env.local

# ログ
*.log
logs/

# テスト
coverage/
.coverage
htmlcov/
.pytest_cache/
EOF

# 7. AI組織設定（オプション）
if [[ "$WITH_AI_ORG" == "true" ]]; then
    print_info "AI組織設定を追加中..."
    
    # AI組織設定のセットアップスクリプトを実行
    "$PROJECT_ROOT/claude-setup-tool/ai-org/setup-ai-org.sh"
    
    print_success "AI組織設定を追加しました"
fi

# 8. 初期設定ログの作成
print_info "初期設定ログを作成中..."
cat > docs/setup-log.md << EOF
# セットアップログ

## 初期設定情報
- 日時: $(date)
- プロジェクト名: $PROJECT_NAME
- 設定タイプ: 基本設定$([ "$WITH_AI_ORG" == "true" ] && echo " + AI組織設定")
- 実行ユーザー: $(whoami)
- 実行ディレクトリ: $PROJECT_DIR

## 作成されたファイル
- CLAUDE.md
- README.md
- .gitignore
- .cursor/rules/ (5ファイル)
$([ "$WITH_AI_ORG" == "true" ] && echo "- .cursor/ai-org/ (2ファイル)")

## 次のステップ
1. Gitリポジトリの初期化: \`git init\`
2. 初回コミット: \`git add . && git commit -m "Initial commit"\`
3. リモートリポジトリの追加: \`git remote add origin <URL>\`
4. プッシュ: \`git push -u origin main\`
EOF

# 9. Gitリポジトリの初期化
print_info "Gitリポジトリを初期化中..."
git init
git add .
git commit -m "Initial commit: Claude Code基本設定$([ "$WITH_AI_ORG" == "true" ] && echo " + AI組織設定")"
print_success "Gitリポジトリを初期化しました"

# 完了メッセージ
print_success "セットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "1. GitHubでリポジトリを作成"
echo "2. git remote add origin <リポジトリURL>"
echo "3. git push -u origin main"
echo ""
echo "プロジェクトディレクトリ: $PROJECT_DIR"