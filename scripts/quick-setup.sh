#!/bin/bash

# Claude Setup Tool - ワンコマンドセットアップスクリプト

set -e

# 設定
REPO_URL="https://github.com/daideguchi/claude-setup-tool"
RAW_URL="https://raw.githubusercontent.com/daideguchi/claude-setup-tool/main"
TEMP_DIR="/tmp/claude-setup-$$"

# フラグ
NEW_PROJECT=""
SETUP_MODE=""
TARGET_DIR="."
BACKUP=true
INTERACTIVE=true

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
  --mode MODE          セットアップモード (basic|ai-org|full)
  --new-project NAME   新しいプロジェクトを作成
  --target DIR         適用先ディレクトリを指定
  --no-backup         バックアップを作成しない
  --non-interactive   対話モードを無効化
  --help              このヘルプを表示

セットアップモード:
  basic      基本設定のみ
  ai-org     AI組織設定のみ
  full       基本設定 + AI組織設定

例:
  # インタラクティブメニュー（推奨）
  $0

  # 基本設定のみを自動適用
  $0 --mode basic --non-interactive

  # 新しいプロジェクトでフル設定
  $0 --new-project "my-app" --mode full --non-interactive

  # 既存プロジェクトにAI組織設定のみ
  $0 --target ./existing-project --mode ai-org --non-interactive
EOF
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            SETUP_MODE="$2"
            shift 2
            ;;
        --new-project)
            NEW_PROJECT="$2"
            shift 2
            ;;
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --no-backup)
            BACKUP=false
            shift
            ;;
        --non-interactive)
            INTERACTIVE=false
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        # 後方互換性のため残す
        --with-ai-org)
            SETUP_MODE="full"
            shift
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
    
    # AI組織関連の依存関係チェック（後で実行）
    return 0
}

# インタラクティブメニュー
show_interactive_menu() {
    if [[ "$INTERACTIVE" != "true" ]]; then
        return
    fi
    
    echo ""
    echo "🚀 Claude Setup Tool へようこそ！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "セットアップモードを選択してください："
    echo ""
    echo "1) 📝 基本設定のみ"
    echo "   - CLAUDE.md (ドキュメント更新システム)"
    echo "   - .cursor/rules/ (Next.js 14 + TypeScript規約)"
    echo "   - 基本的なプロジェクト構造"
    echo ""
    echo "2) 🧑‍💼 AI組織設定のみ"
    echo "   - プロジェクト分析システム"
    echo "   - 組織構成提案（3-8名体制）"
    echo "   - tmuxベースの並列処理"
    echo ""
    echo "3) 🎯 フル設定（基本 + AI組織）"
    echo "   - 上記すべての機能"
    echo "   - エンタープライズ対応"
    echo ""
    echo "4) ❌ キャンセル"
    echo ""
    
    while true; do
        read -p "選択してください [1-4]: " choice
        case $choice in
            1)
                SETUP_MODE="basic"
                print_success "基本設定モードを選択しました"
                break
                ;;
            2)
                SETUP_MODE="ai-org"
                print_success "AI組織設定モードを選択しました"
                break
                ;;
            3)
                SETUP_MODE="full"
                print_success "フル設定モードを選択しました"
                break
                ;;
            4)
                print_info "セットアップをキャンセルしました"
                exit 0
                ;;
            *)
                print_warning "1-4の数字を入力してください"
                ;;
        esac
    done
    
    echo ""
}

# AI組織設定の依存関係チェック
check_ai_org_dependencies() {
    local mode="$1"
    
    if [[ "$mode" != "ai-org" && "$mode" != "full" ]]; then
        return 0
    fi
    
    local missing_ai=()
    
    ! command -v tmux >/dev/null 2>&1 && missing_ai+=("tmux")
    ! command -v jq >/dev/null 2>&1 && missing_ai+=("jq")
    
    if [[ ${#missing_ai[@]} -gt 0 ]]; then
        print_warning "AI組織モードには以下が必要です: ${missing_ai[*]}"
        echo ""
        echo "インストール方法:"
        echo "  macOS: brew install ${missing_ai[*]}"
        echo "  Ubuntu/Debian: sudo apt install ${missing_ai[*]}"
        echo ""
        
        if [[ "$INTERACTIVE" == "true" ]]; then
            read -p "依存関係なしで継続しますか？（シンプルモードで実行）(y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "依存関係をインストールしてから再実行してください"
                exit 1
            fi
            print_info "シンプルモードで実行します"
        else
            print_error "非対話モードでは依存関係が必要です"
            exit 1
        fi
    fi
}

# セットアップファイルをダウンロード
download_setup_files() {
    local mode="$1"
    print_info "セットアップファイルをダウンロード中..."
    
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # 基本ファイル（basic, fullモードで必要）
    if [[ "$mode" == "basic" || "$mode" == "full" ]]; then
        local basic_files=(
            "CLAUDE.md"
            ".cursor/rules/coding-standards.md"
            ".cursor/rules/architecture.md"
            ".cursor/rules/patterns.md"
            ".cursor/rules/troubleshooting.md"
            ".cursor/rules/dependencies.md"
        )
        
        for file in "${basic_files[@]}"; do
            local dir=$(dirname "$file")
            mkdir -p "$dir"
            curl -fsSL "$RAW_URL/$file" -o "$file" || {
                print_error "ダウンロードに失敗しました: $file"
                exit 1
            }
        done
    fi
    
    # AI組織ファイル（ai-org, fullモードで必要）
    if [[ "$mode" == "ai-org" || "$mode" == "full" ]]; then
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
            curl -fsSL "$RAW_URL/$file" -o "$file" || {
                print_warning "AI組織ファイルのダウンロードに失敗: $file"
            }
        done
        
        # AI組織専用CLAUDE.md（基本設定がない場合）
        if [[ "$mode" == "ai-org" ]]; then
            cat > "CLAUDE.md" << 'EOF'
# Claude Code AI組織設定

## AI組織モード

このプロジェクトはClaude Code AI組織機能を使用します。

### 使用方法

```bash
# プロジェクト分析
claude-org analyze

# 組織モード開始
claude-org start

# タスク割り当て
claude-org assign <role_id> <task>

# 進捗確認
claude-org status
```

詳細なドキュメントは `.cursor/ai-org/ROLES.md` を参照してください。
EOF
        fi
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
    local mode="$1"
    print_info "Claude Code設定を適用中..."
    
    # ターゲットディレクトリの確認
    if [[ ! -d "$TARGET_DIR" ]]; then
        print_error "ターゲットディレクトリが存在しません: $TARGET_DIR"
        exit 1
    fi
    
    cd "$TARGET_DIR"
    
    # バックアップ作成
    create_backup
    
    # 基本設定の適用
    if [[ "$mode" == "basic" || "$mode" == "full" ]]; then
        print_info "基本設定を適用中..."
        cp -r "$TEMP_DIR/CLAUDE.md" .
        cp -r "$TEMP_DIR/.cursor" .
        
        # 権限設定
        find .cursor -type f -name "*.md" -exec chmod 644 {} \; 2>/dev/null || true
        
        print_success "基本設定を適用しました"
    fi
    
    # AI組織設定の適用
    if [[ "$mode" == "ai-org" || "$mode" == "full" ]]; then
        print_info "AI組織設定を適用中..."
        
        # AI組織ディレクトリの作成
        mkdir -p scripts/ai-org
        mkdir -p .cursor/ai-org
        
        # AI組織ファイルをコピー
        if [[ -d "$TEMP_DIR/ai-org" ]]; then
            cp -r "$TEMP_DIR/ai-org/scripts/"* scripts/ai-org/ 2>/dev/null || true
            cp -r "$TEMP_DIR/ai-org/templates/"* .cursor/ai-org/ 2>/dev/null || true
            
            # 実行権限を付与
            find scripts/ai-org -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
            
            print_success "AI組織設定を適用しました"
        else
            print_warning "AI組織ファイルが見つかりません"
        fi
        
        # AI組織専用の場合はCLAUDE.mdをコピー
        if [[ "$mode" == "ai-org" ]]; then
            cp "$TEMP_DIR/CLAUDE.md" .
        fi
    fi
    
    # セットアップ完了の表示
    echo ""
    echo "✅ セットアップ完了: $mode モード"
    case $mode in
        basic)
            echo "・基本設定（CLAUDE.md + .cursor/rules）が適用されました"
            ;;
        ai-org)
            echo "・AI組織設定が適用されました"
            echo "・使用方法: ./scripts/ai-org/claude-org.sh analyze"
            ;;
        full)
            echo "・基本設定 + AI組織設定が適用されました"
            echo "・使用方法: ./scripts/ai-org/claude-org.sh analyze"
            ;;
    esac
    echo ""
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

# セットアップモードの決定
determine_setup_mode() {
    # 既にモードが指定されている場合はそのまま使用
    if [[ -n "$SETUP_MODE" ]]; then
        return
    fi
    
    # インタラクティブメニューを表示
    show_interactive_menu
    
    # モードが決定されていない場合はデフォルト
    if [[ -z "$SETUP_MODE" ]]; then
        SETUP_MODE="basic"
        print_info "デフォルトモード（基本設定）を使用します"
    fi
}

# メイン処理
main() {
    print_info "Claude Setup Tool - ワンコマンドセットアップを開始します"
    
    # 基本的な依存関係チェック
    check_dependencies
    
    # セットアップモードの決定
    determine_setup_mode
    
    # AI組織モード用の依存関係チェック
    check_ai_org_dependencies "$SETUP_MODE"
    
    # 新規プロジェクト作成
    create_new_project
    
    # セットアップファイルダウンロード
    download_setup_files "$SETUP_MODE"
    
    # 設定適用
    apply_setup "$SETUP_MODE"
    
    # Git初期化
    init_git
    
    # 完了メッセージ
    print_success "🎉 セットアップが完了しました！"
    echo ""
    echo "📋 次のステップ:"
    
    if [[ -n "$NEW_PROJECT" ]]; then
        echo "1. cd $NEW_PROJECT"
    fi
    
    case $SETUP_MODE in
        basic)
            echo "2. Claude Codeでコーディングを開始"
            echo "3. CLAUDE.mdを確認してルールを把握"
            ;;
        ai-org)
            echo "2. プロジェクト分析: ./scripts/ai-org/claude-org.sh analyze"
            echo "3. 組織モード開始: ./scripts/ai-org/claude-org.sh start"
            ;;
        full)
            echo "2. Claude Codeでコーディングを開始"
            echo "3. AI組織分析: ./scripts/ai-org/claude-org.sh analyze"
            echo "4. 必要に応じて組織モード開始"
            ;;
    esac
    
    echo ""
    echo "📚 ドキュメント:"
    echo "・詳細ガイド: CLAUDE.md"
    echo "・クイックスタート: https://github.com/daideguchi/claude-setup-tool/blob/main/QUICK_START.md"
    
    if [[ "$SETUP_MODE" == "ai-org" || "$SETUP_MODE" == "full" ]]; then
        echo "・AI組織設定: .cursor/ai-org/ROLES.md"
    fi
    
    echo ""
}

# エラー時のクリーンアップ
trap cleanup EXIT

# メイン処理実行
main "$@"