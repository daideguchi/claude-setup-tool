#!/bin/bash

# Claude Code 組織モード管理スクリプト

set -e

# 設定
ORG_CONFIG_DIR=".claude-org"
ORG_CONFIG_FILE="$ORG_CONFIG_DIR/config.json"
ORG_STATE_FILE="$ORG_CONFIG_DIR/state.json"
SESSION_NAME="claude-org"

# 色付き出力
print_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
print_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
print_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }
print_warning() { echo -e "\033[0;33m[WARNING]\033[0m $1"; }

# プロジェクト分析
analyze_project() {
    print_info "プロジェクトを分析中..."
    
    local file_count=$(find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) | wc -l)
    local has_package_json=false
    local has_next_config=false
    local has_dockerfile=false
    local tech_stack=()
    
    [[ -f "package.json" ]] && has_package_json=true
    [[ -f "next.config.js" || -f "next.config.ts" ]] && has_next_config=true
    [[ -f "Dockerfile" ]] && has_dockerfile=true
    
    # 技術スタック検出
    if [[ "$has_next_config" == "true" ]]; then
        tech_stack+=("Next.js")
    elif [[ "$has_package_json" == "true" ]]; then
        tech_stack+=("React/Node.js")
    fi
    
    if grep -q "typescript" package.json 2>/dev/null; then
        tech_stack+=("TypeScript")
    fi
    
    if grep -q "tailwindcss" package.json 2>/dev/null; then
        tech_stack+=("Tailwind CSS")
    fi
    
    if [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then
        tech_stack+=("Python")
    fi
    
    if [[ "$has_dockerfile" == "true" ]]; then
        tech_stack+=("Docker")
    fi
    
    # プロジェクト規模の判定
    local project_size="小規模"
    local recommended_team_size=3
    local estimated_duration="1-3ヶ月"
    
    if [[ $file_count -gt 200 ]]; then
        project_size="大規模"
        recommended_team_size=8
        estimated_duration="6ヶ月以上"
    elif [[ $file_count -gt 50 ]]; then
        project_size="中規模"
        recommended_team_size=6
        estimated_duration="3-6ヶ月"
    fi
    
    # 結果表示
    echo ""
    echo "📊 プロジェクト分析結果"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "・ファイル数: $file_count"
    echo "・プロジェクト規模: $project_size"
    echo "・技術スタック: $(IFS=', '; echo "${tech_stack[*]}")"
    echo "・推定工数: $estimated_duration"
    echo ""
    
    # 組織構成の提案
    echo "🧑‍💼 推奨組織構成 (${recommended_team_size}名体制):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    case $recommended_team_size in
        3)
            echo "1. 👨‍💻 フルスタック開発者 (1名) - フロント・バック両方"
            echo "2. 🎨 UI/UX開発者 (1名) - デザイン・フロントエンド"
            echo "3. 🔧 DevOps (1名) - インフラ・CI/CD・品質管理"
            ;;
        6)
            echo "1. 🏗️  アーキテクト (1名) - 技術決定・設計レビュー"
            echo "2. 🖥️  フロントエンド (2名) - UI/UX・コンポーネント開発"
            echo "3. ⚙️  バックエンド (1名) - API・データベース・ビジネスロジック"
            echo "4. 🔧 DevOps (1名) - インフラ・CI/CD・監視"
            echo "5. 🧪 QA (1名) - テスト・品質保証・リリース管理"
            ;;
        8)
            echo "1. 🏗️  アーキテクト (1名) - 技術決定・設計レビュー"
            echo "2. 🖥️  フロントエンド (2名) - UI/UX・コンポーネント開発"
            echo "3. ⚙️  バックエンド (2名) - API・データベース・マイクロサービス"
            echo "4. 🔧 DevOps (1名) - インフラ・CI/CD・監視"
            echo "5. 🧪 QA (1名) - テスト・品質保証"
            echo "6. 📊 データエンジニア (1名) - データ基盤・分析"
            ;;
    esac
    
    echo ""
    echo "💡 利用可能な構成:"
    echo "・light (3名): 小規模・アジャイル開発"
    echo "・standard (6名): 中規模・バランス型"
    echo "・full (8名): 大規模・本格的開発"
    echo ""
    
    # 設定を保存
    mkdir -p "$ORG_CONFIG_DIR"
    cat > "$ORG_CONFIG_FILE" << EOF
{
  "project_analysis": {
    "file_count": $file_count,
    "project_size": "$project_size",
    "tech_stack": $(printf '%s\n' "${tech_stack[@]}" | jq -R . | jq -s .),
    "recommended_team_size": $recommended_team_size,
    "estimated_duration": "$estimated_duration"
  },
  "analyzed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    print_success "分析完了。推奨構成で開始するには: claude-org start"
}

# 組織構成の定義
get_org_config() {
    local config_type="$1"
    
    case $config_type in
        light)
            echo '{
                "team_size": 3,
                "roles": [
                    {"id": "fullstack", "name": "フルスタック開発者", "responsibilities": ["フロント開発", "バック開発", "API設計"]},
                    {"id": "ui_ux", "name": "UI/UX開発者", "responsibilities": ["デザイン", "フロントエンド", "ユーザビリティ"]},
                    {"id": "devops", "name": "DevOps", "responsibilities": ["インフラ", "CI/CD", "品質管理"]}
                ]
            }'
            ;;
        standard)
            echo '{
                "team_size": 6,
                "roles": [
                    {"id": "architect", "name": "アーキテクト", "responsibilities": ["技術決定", "設計レビュー", "技術指導"]},
                    {"id": "frontend1", "name": "フロントエンド開発者1", "responsibilities": ["UI コンポーネント", "状態管理", "パフォーマンス最適化"]},
                    {"id": "frontend2", "name": "フロントエンド開発者2", "responsibilities": ["ページ実装", "レスポンシブデザイン", "アクセシビリティ"]},
                    {"id": "backend", "name": "バックエンド開発者", "responsibilities": ["API開発", "データベース設計", "ビジネスロジック"]},
                    {"id": "devops", "name": "DevOps", "responsibilities": ["インフラ", "CI/CD", "監視"]},
                    {"id": "qa", "name": "QA", "responsibilities": ["テスト設計", "品質保証", "リリース管理"]}
                ]
            }'
            ;;
        full)
            echo '{
                "team_size": 8,
                "roles": [
                    {"id": "architect", "name": "アーキテクト", "responsibilities": ["技術決定", "設計レビュー", "技術指導"]},
                    {"id": "frontend1", "name": "フロントエンド開発者1", "responsibilities": ["UI システム", "デザインシステム", "パフォーマンス"]},
                    {"id": "frontend2", "name": "フロントエンド開発者2", "responsibilities": ["機能実装", "テスト", "ドキュメント"]},
                    {"id": "backend1", "name": "バックエンド開発者1", "responsibilities": ["API開発", "認証・認可", "セキュリティ"]},
                    {"id": "backend2", "name": "バックエンド開発者2", "responsibilities": ["データベース", "バッチ処理", "外部連携"]},
                    {"id": "devops", "name": "DevOps", "responsibilities": ["インフラ", "CI/CD", "監視・アラート"]},
                    {"id": "qa", "name": "QA", "responsibilities": ["テスト戦略", "自動化", "リリース"]},
                    {"id": "data", "name": "データエンジニア", "responsibilities": ["データ基盤", "分析", "機械学習"]}
                ]
            }'
            ;;
        *)
            # デフォルトは分析結果に基づく
            if [[ -f "$ORG_CONFIG_FILE" ]]; then
                local recommended_size=$(jq -r '.project_analysis.recommended_team_size' "$ORG_CONFIG_FILE")
                case $recommended_size in
                    3) get_org_config "light" ;;
                    6) get_org_config "standard" ;;
                    8) get_org_config "full" ;;
                    *) get_org_config "standard" ;;
                esac
            else
                get_org_config "standard"
            fi
            ;;
    esac
}

# 組織モード開始
start_org_mode() {
    local config_type="$1"
    
    print_info "組織モードを開始中..."
    
    # 設定取得
    local org_config=$(get_org_config "$config_type")
    local team_size=$(echo "$org_config" | jq -r '.team_size')
    
    echo ""
    echo "🚀 組織モード設定"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "・構成: $config_type"
    echo "・チームサイズ: ${team_size}名"
    echo ""
    echo "👥 役割分担:"
    echo "$org_config" | jq -r '.roles[] | "・\(.name): \(.responsibilities | join(", "))"'
    echo ""
    
    # tmuxセッションの確認
    if ! command -v tmux >/dev/null 2>&1; then
        print_warning "tmuxが見つかりません。シンプルモードで実行します"
        start_simple_mode "$org_config"
        return
    fi
    
    # tmuxセッション作成
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        print_warning "既存のセッションを終了しています"
        tmux kill-session -t "$SESSION_NAME"
    fi
    
    # マネージャー用セッション作成
    tmux new-session -d -s "$SESSION_NAME" -n "manager"
    tmux send-keys -t "$SESSION_NAME:manager" "echo '🧑‍💼 組織マネージャー'" C-m
    tmux send-keys -t "$SESSION_NAME:manager" "echo 'チームの統括と進捗管理を行います'" C-m
    tmux send-keys -t "$SESSION_NAME:manager" "echo ''" C-m
    
    # ワーカー用ペイン作成
    local pane_index=1
    echo "$org_config" | jq -r '.roles[] | "\(.id):\(.name)"' | while IFS=':' read -r role_id role_name; do
        if [[ $pane_index -eq 1 ]]; then
            tmux split-window -v -t "$SESSION_NAME:manager"
        else
            tmux split-window -h -t "$SESSION_NAME:manager"
        fi
        
        tmux send-keys -t "$SESSION_NAME:manager.$pane_index" "export ROLE_ID=$role_id" C-m
        tmux send-keys -t "$SESSION_NAME:manager.$pane_index" "export ROLE_NAME='$role_name'" C-m
        tmux send-keys -t "$SESSION_NAME:manager.$pane_index" "echo '👤 $role_name ($role_id)'" C-m
        tmux send-keys -t "$SESSION_NAME:manager.$pane_index" "echo 'タスクの実行を待機中...'" C-m
        tmux send-keys -t "$SESSION_NAME:manager.$pane_index" "echo ''" C-m
        
        ((pane_index++))
    done
    
    # レイアウト調整
    tmux select-layout -t "$SESSION_NAME:manager" even-vertical
    tmux select-pane -t "$SESSION_NAME:manager.0"
    
    # 状態保存
    mkdir -p "$ORG_CONFIG_DIR"
    cat > "$ORG_STATE_FILE" << EOF
{
  "status": "running",
  "config_type": "$config_type",
  "config": $org_config,
  "session_name": "$SESSION_NAME",
  "started_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    print_success "組織モードを開始しました"
    echo ""
    echo "次のステップ:"
    echo "1. tmux attach -t $SESSION_NAME  # セッションに接続"
    echo "2. claude-org assign <role_id> <task>  # タスク割り当て"
    echo "3. claude-org status  # 進捗確認"
    echo ""
    
    # 自動でセッションにアタッチ
    if [[ -t 0 ]]; then
        read -p "セッションに接続しますか？ (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo "後で接続する場合: tmux attach -t $SESSION_NAME"
        else
            tmux attach-session -t "$SESSION_NAME"
        fi
    fi
}

# シンプルモード（tmux不使用）
start_simple_mode() {
    local org_config="$1"
    
    print_info "シンプルモードで組織を開始します"
    
    # 状態保存
    mkdir -p "$ORG_CONFIG_DIR"
    cat > "$ORG_STATE_FILE" << EOF
{
  "status": "running_simple",
  "config": $org_config,
  "started_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    echo ""
    echo "組織メンバー:"
    echo "$org_config" | jq -r '.roles[] | "・\(.id): \(.name)"'
    echo ""
    echo "タスク割り当て例:"
    echo "claude-org assign frontend1 'ログイン画面の実装'"
    
    print_success "シンプルモードで組織を開始しました"
}

# タスク割り当て
assign_task() {
    local role_id="$1"
    local task="$2"
    
    if [[ -z "$role_id" || -z "$task" ]]; then
        print_error "使用方法: claude-org assign <role_id> <task>"
        return 1
    fi
    
    if [[ ! -f "$ORG_STATE_FILE" ]]; then
        print_error "組織モードが開始されていません"
        return 1
    fi
    
    local status=$(jq -r '.status' "$ORG_STATE_FILE")
    
    if [[ "$status" == "running" ]]; then
        # tmuxモード
        if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
            # 該当ペインを探す
            local pane_id=$(tmux list-panes -t "$SESSION_NAME:manager" -F "#{pane_index}" | head -n 10 | tail -n +2 | head -n 1)
            
            if [[ -n "$pane_id" ]]; then
                tmux send-keys -t "$SESSION_NAME:manager.$pane_id" "echo '📋 新しいタスク: $task'" C-m
                tmux send-keys -t "$SESSION_NAME:manager.0" "echo '✅ $role_id にタスクを割り当てました: $task'" C-m
                print_success "タスクを割り当てました: $role_id <- $task"
            else
                print_error "該当する役割が見つかりません: $role_id"
            fi
        else
            print_error "組織セッションが見つかりません"
        fi
    else
        # シンプルモード
        echo "📋 [$role_id] $task" >> "$ORG_CONFIG_DIR/tasks.log"
        print_success "タスクを記録しました: $role_id <- $task"
    fi
}

# 組織状態確認
show_status() {
    if [[ ! -f "$ORG_STATE_FILE" ]]; then
        print_error "組織モードが開始されていません"
        return 1
    fi
    
    local status=$(jq -r '.status' "$ORG_STATE_FILE")
    local config_type=$(jq -r '.config_type // "unknown"' "$ORG_STATE_FILE")
    local started_at=$(jq -r '.started_at' "$ORG_STATE_FILE")
    
    echo ""
    echo "📊 組織状態"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "・状態: $status"
    echo "・構成: $config_type"
    echo "・開始時刻: $started_at"
    echo ""
    
    if [[ "$status" == "running" ]]; then
        if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
            echo "🟢 tmuxセッション: アクティブ"
            echo "・接続方法: tmux attach -t $SESSION_NAME"
        else
            echo "🔴 tmuxセッション: 非アクティブ"
        fi
    fi
    
    echo ""
    echo "👥 チームメンバー:"
    jq -r '.config.roles[] | "・\(.id): \(.name)"' "$ORG_STATE_FILE"
    
    if [[ -f "$ORG_CONFIG_DIR/tasks.log" ]]; then
        echo ""
        echo "📋 最近のタスク:"
        tail -5 "$ORG_CONFIG_DIR/tasks.log" || true
    fi
    
    echo ""
}

# 組織モード停止
stop_org_mode() {
    print_info "組織モードを停止中..."
    
    # tmuxセッション終了
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux kill-session -t "$SESSION_NAME"
        print_success "tmuxセッションを終了しました"
    fi
    
    # 状態ファイル更新
    if [[ -f "$ORG_STATE_FILE" ]]; then
        jq '.status = "stopped" | .stopped_at = "'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'"' "$ORG_STATE_FILE" > "$ORG_STATE_FILE.tmp"
        mv "$ORG_STATE_FILE.tmp" "$ORG_STATE_FILE"
    fi
    
    print_success "組織モードを停止しました"
}

# ヘルプ
show_help() {
    cat << EOF
Claude Code 組織モード管理

使用方法:
  claude-org <command> [options]

コマンド:
  analyze                    プロジェクトを分析して組織構成を提案
  start [light|standard|full] 組織モードを開始
  assign <role_id> <task>    メンバーにタスクを割り当て
  status                     組織の状態を確認
  stop                       組織モードを停止
  help                       このヘルプを表示

組織構成:
  light    (3名): 小規模・アジャイル開発
  standard (6名): 中規模・バランス型 [デフォルト]
  full     (8名): 大規模・本格的開発

例:
  claude-org analyze                    # プロジェクト分析
  claude-org start                      # 推奨構成で開始
  claude-org start light               # 軽量構成で開始
  claude-org assign frontend1 "ログイン画面作成"
  claude-org status                     # 状態確認
  claude-org stop                       # 停止
EOF
}

# メイン処理
main() {
    case "${1:-help}" in
        analyze)
            analyze_project
            ;;
        start)
            start_org_mode "${2:-auto}"
            ;;
        assign)
            assign_task "$2" "$3"
            ;;
        status)
            show_status
            ;;
        stop)
            stop_org_mode
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "不明なコマンド: $1"
            show_help
            exit 1
            ;;
    esac
}

# jqの依存関係チェック
if ! command -v jq >/dev/null 2>&1; then
    print_error "jqが必要です"
    echo "インストール方法:"
    echo "  macOS: brew install jq"
    echo "  Ubuntu/Debian: sudo apt install jq"
    exit 1
fi

main "$@"