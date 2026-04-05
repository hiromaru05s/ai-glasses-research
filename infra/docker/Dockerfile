FROM node:20-slim

# システム依存パッケージ
RUN apt-get update && apt-get install -y \
    git \
    curl \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# YouTube Transcript MCP (オプション)
RUN npm install -g youtube-transcript-mcp || true

# Google Drive アップロード用 Python パッケージ
RUN pip3 install --break-system-packages \
    google-api-python-client \
    google-auth

# 作業ディレクトリ
WORKDIR /app

# プロジェクトファイルをコピー
COPY CLAUDE.md sources.md ./
COPY skills/ ./skills/
COPY scripts/ ./scripts/

# レポート出力ディレクトリ
RUN mkdir -p reports/daily reports/weekly

# 実行スクリプト
COPY infra/docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
