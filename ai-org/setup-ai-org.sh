#!/bin/bash

# AI組織設定セットアップスクリプト

set -e

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

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_ORG_DIR="$(dirname "$SCRIPT_DIR")"
SETUP_TOOL_DIR="$(dirname "$AI_ORG_DIR")"

# プロジェクトディレクトリの確認
check_project_dir() {
    if [[ ! -f "CLAUDE.md" ]]; then
        print_error "このディレクトリはClaude Codeプロジェクトではありません"
        print_info "先に基本設定を実行してください: $SETUP_TOOL_DIR/scripts/setup.sh"
        exit 1
    fi
}

# AI組織設定のインストール
install_ai_org() {
    print_info "AI組織設定をインストール中..."
    
    # .cursor/ai-orgディレクトリの作成
    mkdir -p .cursor/ai-org
    
    # テンプレートファイルのコピー
    cp "$AI_ORG_DIR/templates/ROLES.md" .cursor/ai-org/
    
    # スクリプトディレクトリの作成とコピー
    mkdir -p scripts/ai-org
    cp "$AI_ORG_DIR/scripts/tmux-session.sh" scripts/ai-org/
    cp "$AI_ORG_DIR/scripts/task-distributor.sh" scripts/ai-org/
    chmod +x scripts/ai-org/*.sh
    
    print_success "AI組織設定ファイルをインストールしました"
}

# CLAUDE.mdの更新
update_claude_md() {
    print_info "CLAUDE.mdを更新中..."
    
    # AI組織設定セクションの追加
    cat >> CLAUDE.md << EOF

## AI組織設定

### AI組織の活用
このプロジェクトはAI組織機能を有効にしています。

#### 使用方法
1. tmuxセッションの起動: \`./scripts/ai-org/tmux-session.sh create\`
2. タスクの分配: \`./scripts/ai-org/task-distributor.sh distribute\`
3. ステータス確認: \`./scripts/ai-org/task-distributor.sh status\`

#### 組織構造
- マネージャー: 1名（タスク分配と進捗管理）
- ワーカー: 5名（タスク実行）

詳細は \`.cursor/ai-org/ROLES.md\` を参照してください。

### 更新履歴
- $(date +%Y-%m-%d): AI組織設定を追加
EOF
    
    print_success "CLAUDE.mdを更新しました"
}

# 使用ガイドの作成
create_usage_guide() {
    print_info "使用ガイドを作成中..."
    
    cat > docs/ai-org-guide.md << EOF
# AI組織機能の使用ガイド

## 概要
AI組織機能は、複数のClaude Codeインスタンスを協調させて、大規模なタスクを効率的に処理するシステムです。

## セットアップ

### 前提条件
- tmuxがインストールされていること
- Claude Codeが使用可能であること

### 初回セットアップ
\`\`\`bash
# AI組織セッションの作成
./scripts/ai-org/tmux-session.sh create
\`\`\`

## 基本的な使い方

### 1. タスクの分配
\`\`\`bash
# 対話的にタスクを入力
./scripts/ai-org/task-distributor.sh distribute

# ファイルからタスクを読み込み
./scripts/ai-org/task-distributor.sh file tasks.txt
\`\`\`

### 2. ステータス確認
\`\`\`bash
./scripts/ai-org/task-distributor.sh status
\`\`\`

### 3. 全ペインのクリア
\`\`\`bash
./scripts/ai-org/task-distributor.sh clear
\`\`\`

## タスクファイルの形式
\`\`\`
# コメント行
src/componentsのリファクタリング
テストケースの作成
ドキュメントの更新
パフォーマンスの最適化
バグ修正 #123
\`\`\`

## tmuxキーバインド
- \`Ctrl+b\` + \`数字\`: ペインの切り替え
- \`Ctrl+b\` + \`z\`: ペインの最大化/復元
- \`Ctrl+b\` + \`d\`: セッションからデタッチ

## トラブルシューティング

### セッションが見つからない
\`\`\`bash
# セッションの再作成
./scripts/ai-org/tmux-session.sh create
\`\`\`

### タスクが実行されない
1. 各ペインでClaude Codeが起動しているか確認
2. \`claude\`コマンドを手動で実行

## ベストプラクティス
1. タスクは独立性の高いものを選ぶ
2. 定期的にステータスを確認する
3. エラーが発生したら早めに対処する
4. 長時間のセッションでは定期的に/clearを実行
EOF
    
    print_success "使用ガイドを作成しました"
}

# サンプルタスクファイルの作成
create_sample_tasks() {
    print_info "サンプルタスクファイルを作成中..."
    
    cat > sample-tasks.txt << EOF
# サンプルタスクファイル
# 1行に1つのタスクを記述します

READMEファイルの内容を充実させる
srcディレクトリ構造の最適化を検討
ユニットテストのカバレッジを向上させる
エラーハンドリングの改善
パフォーマンスボトルネックの特定
EOF
    
    print_success "サンプルタスクファイルを作成しました"
}

# メイン処理
main() {
    print_info "AI組織設定のセットアップを開始します"
    
    # プロジェクトディレクトリの確認
    check_project_dir
    
    # 既存のAI組織設定をチェック
    if [[ -d ".cursor/ai-org" ]]; then
        print_warning "AI組織設定は既にインストールされています"
        read -p "上書きしますか？ (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "セットアップをキャンセルしました"
            exit 0
        fi
    fi
    
    # インストール実行
    install_ai_org
    update_claude_md
    create_usage_guide
    create_sample_tasks
    
    print_success "AI組織設定のセットアップが完了しました！"
    echo ""
    echo "次のステップ:"
    echo "1. tmuxセッションを開始: ./scripts/ai-org/tmux-session.sh create"
    echo "2. 各ペインでclaude codeを起動"
    echo "3. タスクを分配: ./scripts/ai-org/task-distributor.sh distribute"
    echo ""
    echo "詳細は docs/ai-org-guide.md を参照してください。"
}

main "$@"