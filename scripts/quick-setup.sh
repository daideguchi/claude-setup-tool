#!/bin/bash

# Claude Setup Tool - ワンコマンドセットアップスクリプト

set -e

# 設定
REPO_URL="https://github.com/daideguchi/claude-setup-tool"
RAW_URL="https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main"
TEMP_DIR="/tmp/claude-setup-$$"

# フラグ
NEW_PROJECT=""
WITH_AI_ORG=false
TARGET_DIR="."
BACKUP=true

# 色付き出力
print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

print_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1"
}

# ヘルプ表示
show_help() {
    cat << EOF
Claude Setup Tool - ワンコマンドセットアップ

使用方法:
  $0 [オプション]

オプション:
  --new-project NAME    新しいプロジェクトを作成
  --with-ai-org         AI組織設定も含める
  --target DIR          適用先ディレクトリを指定
  --no-backup          バックアップを作成しない
  --help               このヘルプを表示

例:
  # カレントディレクトリに基本設定を適用
  $0

  # 新しいプロジェクトを作成
  $0 --new-project "my-app"

  # AI組織設定も含める
  $0 --with-ai-org

  # 既存プロジェクトに適用（バックアップなし）
  $0 --target ./existing-project --no-backup
EOF
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --new-project)
            NEW_PROJECT="$2"
            shift 2
            ;;
        --with-ai-org)
            WITH_AI_ORG=true
            shift
            ;;
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --no-backup)
            BACKUP=false
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "不明なオプション: $1"
            show_help
            exit 1
            ;;
    esac
done

# 依存関係チェック
check_dependencies() {
    local missing=()
    
    command -v git >/dev/null 2>&1 || missing+=("git")
    command -v curl >/dev/null 2>&1 || missing+=("curl")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_error "必要なコマンドが見つかりません: ${missing[*]}"
        echo "インストール方法:"
        echo "  macOS: brew install ${missing[*]}"
        echo "  Ubuntu/Debian: sudo apt install ${missing[*]}"
        exit 1
    fi
    
    if [[ "$WITH_AI_ORG" == "true" ]] && ! command -v tmux >/dev/null 2>&1; then
        print_warning "AI組織モードにはtmuxが必要です"
        echo "インストール方法:"
        echo "  macOS: brew install tmux"
        echo "  Ubuntu/Debian: sudo apt install tmux"
        read -p "tmux なしで継続しますか？ (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        WITH_AI_ORG=false
    fi
}

# セットアップファイルをダウンロード
download_setup_files() {
    print_info "セットアップファイルをダウンロード中..."
    
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # 必要なファイルをダウンロード
    local files=(
        "CLAUDE.md"
        ".cursor/rules/coding-standards.md"
        ".cursor/rules/architecture.md"
        ".cursor/rules/patterns.md"
        ".cursor/rules/troubleshooting.md"
        ".cursor/rules/dependencies.md"
    )
    
    for file in "${files[@]}"; do
        local dir=$(dirname "$file")
        mkdir -p "$dir"
        curl -fsSL "$RAW_URL/$file" -o "$file" || {
            print_error "ダウンロードに失敗しました: $file"
            exit 1
        }
    done
    
    if [[ "$WITH_AI_ORG" == "true" ]]; then
        local ai_files=(
            "ai-org/setup-ai-org.sh"
            "ai-org/scripts/tmux-session.sh"
            "ai-org/scripts/task-distributor.sh"
            "ai-org/scripts/claude-org.sh"
            "ai-org/templates/ROLES.md"
        )
        
        for file in "${ai_files[@]}"; do
            local dir=$(dirname "$file")
            mkdir -p "$dir"
            curl -fsSL "$RAW_URL/$file" -o "$file" 2>/dev/null || {
                print_warning "AI組織ファイルのダウンロードに失敗: $file"
            }
        done
    fi
    
    print_success "ファイルのダウンロードが完了しました"
}

# 新規プロジェクト作成
create_new_project() {
    if [[ -z "$NEW_PROJECT" ]]; then
        return
    fi
    
    print_info "新しいプロジェクト '$NEW_PROJECT' を作成中..."
    
    if [[ -d "$NEW_PROJECT" ]]; then
        print_error "ディレクトリ '$NEW_PROJECT' は既に存在します"
        exit 1
    fi
    
    mkdir -p "$NEW_PROJECT"/{src,docs,tests,scripts}
    TARGET_DIR="$NEW_PROJECT"
    
    # 基本的なファイルを作成
    cat > "$NEW_PROJECT/README.md" << EOF
# $NEW_PROJECT

Claude Codeを使用して初期設定されたプロジェクトです。

## セットアップ

\`\`\`bash
# 依存関係のインストール
npm install

# 開発サーバーの起動
npm run dev
\`\`\`

## Claude Code 組織モード

\`\`\`bash
# 組織モードの開始
claude-org start

# 進捗確認
claude-org status
\`\`\`
EOF
    
    # package.jsonの作成（Next.js想定）
    cat > "$NEW_PROJECT/package.json" << EOF
{
  "name": "$NEW_PROJECT",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "^18",
    "react-dom": "^18"
  },
  "devDependencies": {
    "typescript": "^5",
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "eslint": "^8",
    "eslint-config-next": "14.0.0"
  }
}
EOF
    
    print_success "新しいプロジェクト '$NEW_PROJECT' を作成しました"
}

# バックアップ作成
create_backup() {
    if [[ "$BACKUP" == "false" ]]; then
        return
    fi
    
    local backup_dir="$TARGET_DIR/.claude-backup-$(date +%Y%m%d-%H%M%S)"
    local files_to_backup=()
    
    # 既存ファイルをチェック
    [[ -f "$TARGET_DIR/CLAUDE.md" ]] && files_to_backup+=("CLAUDE.md")
    [[ -d "$TARGET_DIR/.cursor" ]] && files_to_backup+=(".cursor")
    
    if [[ ${#files_to_backup[@]} -gt 0 ]]; then
        print_info "既存ファイルをバックアップ中..."
        mkdir -p "$backup_dir"
        
        for file in "${files_to_backup[@]}"; do
            cp -r "$TARGET_DIR/$file" "$backup_dir/" 2>/dev/null || true
        done
        
        print_success "バックアップを作成しました: $backup_dir"
    fi
}

# 設定ファイルを適用
apply_setup() {
    print_info "Claude Code設定を適用中..."
    
    # ターゲットディレクトリの確認
    if [[ ! -d "$TARGET_DIR" ]]; then
        print_error "ターゲットディレクトリが存在しません: $TARGET_DIR"
        exit 1
    fi
    
    cd "$TARGET_DIR"
    
    # バックアップ作成
    create_backup
    
    # 設定ファイルをコピー
    cp -r "$TEMP_DIR/CLAUDE.md" .
    cp -r "$TEMP_DIR/.cursor" .
    
    # 権限設定
    find .cursor -type f -name "*.md" -exec chmod 644 {} \;
    
    print_success "基本設定を適用しました"
}

# AI組織設定を適用
apply_ai_org() {
    if [[ "$WITH_AI_ORG" != "true" ]]; then
        return
    fi
    
    print_info "AI組織設定を適用中..."
    
    # AI組織ディレクトリの作成
    mkdir -p scripts/ai-org
    mkdir -p .cursor/ai-org
    
    # AI組織ファイルをコピー
    if [[ -d "$TEMP_DIR/ai-org" ]]; then
        cp -r "$TEMP_DIR/ai-org/scripts/"* scripts/ai-org/ 2>/dev/null || true
        cp -r "$TEMP_DIR/ai-org/templates/"* .cursor/ai-org/ 2>/dev/null || true
        
        # 実行権限を付与
        find scripts/ai-org -type f -name "*.sh" -exec chmod +x {} \;
        
        print_success "AI組織設定を適用しました"
    else
        print_warning "AI組織ファイルが見つかりません"
    fi
}

# Git初期化
init_git() {
    if [[ ! -d ".git" ]]; then
        print_info "Gitリポジトリを初期化中..."
        git init
        git add .
        git commit -m "Initial commit: Claude Code setup"
        print_success "Gitリポジトリを初期化しました"
    else
        print_info "既存のGitリポジトリに追加中..."
        git add .
        git commit -m "feat: Claude Code setup applied" || {
            print_warning "コミットに失敗しました（変更がない可能性があります）"
        }
    fi
}

# クリーンアップ
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# メイン処理
main() {
    print_info "Claude Setup Tool - ワンコマンドセットアップを開始します"
    
    # 依存関係チェック
    check_dependencies
    
    # 新規プロジェクト作成
    create_new_project
    
    # セットアップファイルダウンロード
    download_setup_files
    
    # 設定適用
    apply_setup
    apply_ai_org
    
    # Git初期化
    init_git
    
    # 完了メッセージ
    print_success "セットアップが完了しました！"
    echo ""
    echo "次のステップ:"
    
    if [[ -n "$NEW_PROJECT" ]]; then
        echo "1. cd $NEW_PROJECT"
    fi
    
    echo "2. コーディングを開始してください"
    
    if [[ "$WITH_AI_ORG" == "true" ]]; then
        echo "3. AI組織モードを開始: ./scripts/ai-org/claude-org.sh start"
    fi
    
    echo ""
    echo "詳細なドキュメント: CLAUDE.md"
    echo "クイックスタートガイド: https://github.com/daideguchi/claude-setup-tool/blob/main/QUICK_START.md"
}

# エラー時のクリーンアップ
trap cleanup EXIT

# メイン処理実行
main "$@"