#!/bin/bash
set -e

TODAY=$(TZ=Asia/Tokyo date +%Y-%m-%d)
REPORT_PATH="reports/daily/${TODAY}.md"

echo "=== AIグラス市場シンクタンク: 日次調査 ==="
echo "Date: ${TODAY}"
echo "Model: ${MODEL:-opus}"
echo "Budget: $${MAX_BUDGET:-5}"

# Claude Code をヘッドレスで実行
claude -p "
あなたはAIグラス市場シンクタンクのリサーチエージェントです。
CLAUDE.mdとskills/daily-research/SKILL.mdの内容に従って、
本日(${TODAY})の日次調査レポートを作成してください。

レポートは ${REPORT_PATH} に保存してください。

重要:
- Web検索で最新情報を収集すること
- 全事実にソースURLを付記すること
- 予算\$${MAX_BUDGET:-5}以下に収めること
" \
  --model "${MODEL:-opus}" \
  --max-budget-usd "${MAX_BUDGET:-5}" \
  --allowedTools "WebSearch,Read,Write,Edit,Bash"

echo "=== レポート生成完了 ==="

# レポートが生成されたか確認
if [ -f "${REPORT_PATH}" ]; then
    echo "レポート: ${REPORT_PATH}"
    echo "サイズ: $(wc -c < "${REPORT_PATH}") bytes"

    # Google Drive アップロード（環境変数が設定されていれば）
    if [ -n "${GDRIVE_SERVICE_ACCOUNT}" ] && [ -n "${GDRIVE_FOLDER_ID}" ]; then
        echo "=== Google Driveにアップロード中 ==="
        python3 scripts/upload_to_gdrive.py "${REPORT_PATH}"
        echo "=== アップロード完了 ==="
    else
        echo "Google Drive未設定: スキップ"
    fi

    # S3アップロード（環境変数が設定されていれば）
    if [ -n "${S3_BUCKET}" ]; then
        echo "=== S3にアップロード中 ==="
        aws s3 cp "${REPORT_PATH}" "s3://${S3_BUCKET}/reports/daily/${TODAY}.md"
        echo "=== S3アップロード完了 ==="
    fi
else
    echo "ERROR: レポートが生成されませんでした"
    exit 1
fi
