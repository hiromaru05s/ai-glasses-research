#!/bin/bash
# ============================================================
# AIグラス市場シンクタンク — 日次デルタレポート実行スクリプト
# ローカルで claude -p ヘッドレス実行 → GDrive → Git Push
# ============================================================
set -e

# --- 設定 ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TODAY=$(TZ=Asia/Tokyo date +%Y-%m-%d)
MODEL="${MODEL:-opus}"
MAX_BUDGET="${MAX_BUDGET:-5}"

echo "==========================================="
echo " AIグラス市場シンクタンク: 日次デルタレポート"
echo " Date: ${TODAY}"
echo " Model: ${MODEL}"
echo " Budget: \$${MAX_BUDGET}"
echo "==========================================="

cd "$PROJECT_DIR"

# --- Claude Code ヘッドレス実行 ---
claude -p "
あなたはAIグラス市場シンクタンクのリサーチエージェントです。

以下のファイルを順番に読んでから作業を開始すること:
1. CLAUDE.md（組織の憲法）
2. skills/daily-research/SKILL.md（スキル定義）
3. sources.md（監視対象ソース一覧）

SKILL.mdの「モード1: 日次デルタレポート」を実行してください。
日付は ${TODAY} です。

重要:
- X/TwitterとYouTubeの2ソースのみ使用すること
- 全アイテムに @ユーザー名+URL または チャンネル名+URL を必ず記載
- known-items.json を先に読み、デルタ（差分）のみ報告
- レポートは reports/daily/${TODAY}.md に保存
- Google DriveのMCPが使える場合、daily-delta/ フォルダにアップロード
- ソース取得に失敗した場合、原因と対策をレポート末尾に記載
" \
  --model "${MODEL}" \
  --max-budget-usd "${MAX_BUDGET}" \
  --allowedTools "WebSearch,Read,Write,Edit,Bash,mcp__youtube-transcript,mcp__x-twitter,mcp__google-drive"

echo ""
echo "=== レポート生成完了 ==="

# --- レポート確認 ---
REPORT="reports/daily/${TODAY}.md"
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

    # 差分がある場合のみcommit
    if git diff --cached --quiet; then
        echo "変更なし — コミットをスキップ"
    else
        ITEM_COUNT=$(python3 -c "
import json
with open('reports/state/known-items.json') as f:
    data = json.load(f)
print(len(data.get('items', {})))
" 2>/dev/null || echo "?")
        git commit -m "daily: ${TODAY} — ${ITEM_COUNT} total items"
        git push origin main
        echo "Git Push 完了"
    fi
else
    echo "WARNING: Gitリポジトリが初期化されていません"
    echo "  → 'git init && git remote add origin <URL>' を先に実行してください"
fi

echo ""
echo "=== 完了 ==="
