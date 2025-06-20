#!/bin/bash

# AI組織用tmuxセッション管理スクリプト

set -e

# 設定
SESSION_NAME="ai-org"
MAIN_PANE_NAME="manager"
WORKER_PREFIX="worker"
WORKER_COUNT=5

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

# tmuxのインストール確認
check_tmux() {
    if ! command -v tmux &> /dev/null; then
        print_error "tmuxがインストールされていません"
        echo "インストール方法:"
        echo "  macOS: brew install tmux"
        echo "  Ubuntu/Debian: sudo apt install tmux"
        exit 1
    fi
}

# セッションの作成
create_session() {
    # 既存のセッションをチェック
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        print_error "セッション '$SESSION_NAME' は既に存在します"
        read -p "既存のセッションを削除しますか？ (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            tmux kill-session -t "$SESSION_NAME"
        else
            exit 1
        fi
    fi

    print_info "AI組織用tmuxセッションを作成中..."

    # メインセッション（マネージャー）を作成
    tmux new-session -d -s "$SESSION_NAME" -n "$MAIN_PANE_NAME"
    
    # レイアウト設定: メインペインを上部に、ワーカーを下部に配置
    # まず画面を上下に分割（メイン70%、ワーカー30%）
    tmux split-window -v -p 30 -t "$SESSION_NAME:$MAIN_PANE_NAME"
    
    # ワーカーエリアを横に分割
    for ((i=2; i<=$WORKER_COUNT; i++)); do
        tmux split-window -h -t "$SESSION_NAME:$MAIN_PANE_NAME"
        tmux select-layout -t "$SESSION_NAME:$MAIN_PANE_NAME" even-horizontal
    done

    # 各ペインにIDを設定（環境変数として）
    tmux send-keys -t "$SESSION_NAME:$MAIN_PANE_NAME.0" "export AI_ROLE=manager" C-m
    tmux send-keys -t "$SESSION_NAME:$MAIN_PANE_NAME.0" "export AI_PANE_ID=0" C-m
    
    for ((i=1; i<=$WORKER_COUNT; i++)); do
        tmux send-keys -t "$SESSION_NAME:$MAIN_PANE_NAME.$i" "export AI_ROLE=worker$i" C-m
        tmux send-keys -t "$SESSION_NAME:$MAIN_PANE_NAME.$i" "export AI_PANE_ID=$i" C-m
    done

    # レイアウトを調整
    tmux select-pane -t "$SESSION_NAME:$MAIN_PANE_NAME.0"
    
    print_success "AI組織用tmuxセッションを作成しました"
}

# Claude Codeの起動
start_claude() {
    print_info "各ペインでClaude Codeを起動中..."
    
    # マネージャーペイン
    tmux send-keys -t "$SESSION_NAME:$MAIN_PANE_NAME.0" "echo '# AI組織マネージャー'" C-m
    tmux send-keys -t "$SESSION_NAME:$MAIN_PANE_NAME.0" "echo 'タスクを分配し、全体を統括します'" C-m
    tmux send-keys -t "$SESSION_NAME:$MAIN_PANE_NAME.0" "# claude" C-m
    
    # ワーカーペイン
    for ((i=1; i<=$WORKER_COUNT; i++)); do
        tmux send-keys -t "$SESSION_NAME:$MAIN_PANE_NAME.$i" "echo '# AI組織ワーカー$i'" C-m
        tmux send-keys -t "$SESSION_NAME:$MAIN_PANE_NAME.$i" "echo 'マネージャーからのタスクを実行します'" C-m
        tmux send-keys -t "$SESSION_NAME:$MAIN_PANE_NAME.$i" "# claude" C-m
    done
}

# セッションをアタッチ
attach_session() {
    print_info "セッションにアタッチしています..."
    tmux attach-session -t "$SESSION_NAME"
}

# メイン処理
main() {
    case "${1:-create}" in
        create)
            check_tmux
            create_session
            start_claude
            attach_session
            ;;
        attach)
            tmux attach-session -t "$SESSION_NAME"
            ;;
        kill)
            tmux kill-session -t "$SESSION_NAME"
            print_success "セッションを終了しました"
            ;;
        list)
            echo "現在のペイン一覧:"
            tmux list-panes -t "$SESSION_NAME" -F "Pane #{pane_index}: #{pane_current_command}"
            ;;
        *)
            echo "使用方法: $0 {create|attach|kill|list}"
            echo "  create - 新しいAI組織セッションを作成"
            echo "  attach - 既存のセッションにアタッチ"
            echo "  kill   - セッションを終了"
            echo "  list   - ペイン一覧を表示"
            exit 1
            ;;
    esac
}

main "$@"