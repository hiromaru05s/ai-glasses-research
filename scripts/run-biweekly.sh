#!/bin/bash
# ============================================================
# AIグラス市場シンクタンク — 隔週サマリーレポート実行スクリプト
# known-items.json の蓄積情報を棚卸し → GDrive → Git Push
# ============================================================
set -e

# --- 設定 ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TODAY=$(TZ=Asia/Tokyo date +%Y-%m-%d)
MODEL="${MODEL:-opus}"
MAX_BUDGET="${MAX_BUDGET:-3}"

echo "==========================================="
echo " AIグラス市場シンクタンク: 隔週サマリーレポート"
echo " Date: ${TODAY}"
echo " Model: ${MODEL}"
echo " Budget: \$${MAX_BUDGET}"
echo "==========================================="

cd "$PROJECT_DIR"

# --- 隔週チェック ---
# known-items.json の last_biweekly を読んで14日経過しているか確認
SHOULD_RUN=$(python3 -c "
import json, datetime
try:
    with open('reports/state/known-items.json') as f:
        data = json.load(f)
    last = data.get('last_biweekly')
    if not last:
        print('yes')
    else:
        delta = (datetime.date.today() - datetime.date.fromisoformat(last)).days
        print('yes' if delta >= 14 else 'no')
except:
    print('yes')
" 2>/dev/null || echo "yes")

if [ "$SHOULD_RUN" = "no" ] && [ "$1" != "--force" ]; then
    echo "前回の隔週レポートから14日未経過。スキップします。"
    echo "  → 強制実行するには: $0 --force"
    exit 0
fi

# --- Claude Code ヘッドレス実行 ---
claude -p "
あなたはAIグラス市場シンクタンクのリサーチエージェントです。

以下のファイルを順番に読んでから作業を開始すること:
1. CLAUDE.md（組織の憲法）
2. skills/daily-research/SKILL.md（スキル定義）

SKILL.mdの「モード2: 隔週サマリーレポート」を実行してください。
日付は ${TODAY} です。

重要:
- reports/state/known-items.json の蓄積情報を全て読み込む
- カテゴリ別に整理し、トレンド分析まで行う
- 全アイテムに引用元（@ユーザー名+URL or チャンネル名+URL）を保持
- レポートは reports/biweekly/${TODAY}.md に保存
- Google DriveのMCPが使える場合、biweekly-summary/ フォルダにアップロード
- last_biweekly を今日の日付に更新
" \
  --model "${MODEL}" \
  --max-budget-usd "${MAX_BUDGET}" \
  --allowedTools "Read,Write,Edit,Bash,mcp__google-drive"

echo ""
echo "=== レポート生成完了 ==="

# --- レポート確認 ---
REPORT="reports/biweekly/${TODAY}.md"
if [ -f "$REPORT" ]; then
    echo "レポート: ${REPORT}"
    echo "サイズ: $(wc -c < "$REPORT") bytes"
else
    echo "WARNING: レポートファイルが見つかりません: ${REPORT}"
fi

# --- Git Commit & Push ---
echo ""
echo "=== Git Push ==="
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    git add reports/state/known-items.json
    [ -f "$REPORT" ] && git add "$REPORT"

    if git diff --cached --quiet; then
        echo "変更なし — コミットをスキップ"
    else
        ITEM_COUNT=$(python3 -c "
import json
with open('reports/state/known-items.json') as f:
    data = json.load(f)
print(len(data.get('items', {})))
" 2>/dev/null || echo "?")
        git commit -m "biweekly: ${TODAY} — ${ITEM_COUNT} total items"
        git push origin main
        echo "Git Push 完了"
    fi
else
    echo "WARNING: Gitリポジトリが初期化されていません"
fi

echo ""
echo "=== 完了 ==="
