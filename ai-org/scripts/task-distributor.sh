#!/bin/bash

# AI組織タスク分配システム

set -e

# 設定
SESSION_NAME="ai-org"
MAIN_PANE="$SESSION_NAME:manager.0"
TASK_QUEUE_DIR="/tmp/ai-org-tasks"
TASK_LOG="$TASK_QUEUE_DIR/task.log"

# タスクキューディレクトリの作成
mkdir -p "$TASK_QUEUE_DIR"

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

# タスクをワーカーに送信
send_task_to_worker() {
    local worker_id=$1
    local task=$2
    local pane_id="$SESSION_NAME:manager.$worker_id"
    
    # タスクを送信
    tmux send-keys -t "$pane_id" "$task" C-m
    
    # ログに記録
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Worker$worker_id: $task" >> "$TASK_LOG"
}

# マネージャーにメッセージを送信
send_to_manager() {
    local message=$1
    tmux send-keys -t "$MAIN_PANE" "$message" C-m
}

# タスク分配
distribute_tasks() {
    print_info "タスクを入力してください（空行で終了）:"
    
    local tasks=()
    while true; do
        read -p "> " task
        [[ -z "$task" ]] && break
        tasks+=("$task")
    done
    
    if [ ${#tasks[@]} -eq 0 ]; then
        print_error "タスクが入力されていません"
        return 1
    fi
    
    print_info "${#tasks[@]}個のタスクを分配します"
    
    # マネージャーに全体タスクを通知
    send_to_manager "# 新しいタスクセットを受信しました"
    send_to_manager "# タスク数: ${#tasks[@]}"
    send_to_manager ""
    
    # タスクを各ワーカーに分配
    local worker_count=5
    local task_index=0
    
    for task in "${tasks[@]}"; do
        local worker_id=$((task_index % worker_count + 1))
        
        # マネージャーに分配情報を送信
        send_to_manager "ワーカー$worker_id に割り当て: $task"
        
        # ワーカーにタスクを送信
        send_task_to_worker "$worker_id" "# タスク: $task"
        
        ((task_index++))
    done
    
    send_to_manager ""
    send_to_manager "# 全タスクの分配が完了しました"
    
    print_success "タスク分配が完了しました"
}

# タスクファイルから読み込んで分配
distribute_from_file() {
    local file=$1
    
    if [[ ! -f "$file" ]]; then
        print_error "ファイルが見つかりません: $file"
        return 1
    fi
    
    print_info "ファイルからタスクを読み込んでいます: $file"
    
    # ファイルから1行ずつ読み込んで配列に格納
    local tasks=()
    while IFS= read -r line; do
        # 空行とコメント行をスキップ
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        tasks+=("$line")
    done < "$file"
    
    if [ ${#tasks[@]} -eq 0 ]; then
        print_error "タスクが見つかりません"
        return 1
    fi
    
    print_info "${#tasks[@]}個のタスクを分配します"
    
    # タスクを分配
    local worker_count=5
    local task_index=0
    
    send_to_manager "# ファイルからタスクを読み込みました: $file"
    send_to_manager "# タスク数: ${#tasks[@]}"
    send_to_manager ""
    
    for task in "${tasks[@]}"; do
        local worker_id=$((task_index % worker_count + 1))
        send_to_manager "ワーカー$worker_id に割り当て: $task"
        send_task_to_worker "$worker_id" "# タスク: $task"
        ((task_index++))
    done
    
    send_to_manager ""
    send_to_manager "# 全タスクの分配が完了しました"
    
    print_success "タスク分配が完了しました"
}

# タスクのステータスを確認
check_status() {
    print_info "各ワーカーにステータス確認を送信します"
    
    send_to_manager "# ステータス確認を開始します"
    
    for i in {1..5}; do
        send_task_to_worker "$i" "# ステータス報告をお願いします"
    done
    
    print_success "ステータス確認を送信しました"
}

# 全ワーカーをクリア
clear_all() {
    print_info "全ペインで/clearを実行します"
    
    # マネージャーをクリア
    tmux send-keys -t "$MAIN_PANE" "/clear" C-m
    
    # 各ワーカーをクリア
    for i in {1..5}; do
        tmux send-keys -t "$SESSION_NAME:manager.$i" "/clear" C-m
    done
    
    print_success "全ペインをクリアしました"
}

# メイン処理
main() {
    # セッションの存在確認
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        print_error "AI組織セッションが存在しません"
        echo "先に './ai-org/scripts/tmux-session.sh create' を実行してください"
        exit 1
    fi
    
    case "${1:-help}" in
        distribute)
            distribute_tasks
            ;;
        file)
            if [[ -z "$2" ]]; then
                print_error "ファイル名を指定してください"
                exit 1
            fi
            distribute_from_file "$2"
            ;;
        status)
            check_status
            ;;
        clear)
            clear_all
            ;;
        log)
            if [[ -f "$TASK_LOG" ]]; then
                cat "$TASK_LOG"
            else
                print_info "タスクログはまだありません"
            fi
            ;;
        help|*)
            echo "使用方法: $0 {distribute|file|status|clear|log|help}"
            echo ""
            echo "コマンド:"
            echo "  distribute - 対話的にタスクを入力して分配"
            echo "  file <file> - ファイルからタスクを読み込んで分配"
            echo "  status     - 全ワーカーのステータスを確認"
            echo "  clear      - 全ペインをクリア"
            echo "  log        - タスク分配ログを表示"
            echo "  help       - このヘルプを表示"
            echo ""
            echo "タスクファイルの形式:"
            echo "  - 1行1タスク"
            echo "  - 空行は無視"
            echo "  - #で始まる行はコメント"
            ;;
    esac
}

main "$@"