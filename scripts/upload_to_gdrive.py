"""
Google Drive アップロードスクリプト
GitHub Actionsから呼び出され、日次レポートをGoogle Driveにアップロードする

必要な環境変数:
  GDRIVE_SERVICE_ACCOUNT: サービスアカウントのJSONキー（GitHub Secretsに格納）
  GDRIVE_FOLDER_ID: アップロード先のGoogle DriveフォルダID

セットアップ手順:
  1. Google Cloud Console でプロジェクト作成
  2. Google Drive API を有効化
  3. サービスアカウント作成 → JSONキーをダウンロード
  4. Google Driveでアップロード先フォルダを作成
  5. フォルダをサービスアカウントのメールアドレスに共有（編集者権限）
  6. GitHub Secrets に GDRIVE_SERVICE_ACCOUNT (JSONの中身) と GDRIVE_FOLDER_ID を登録
"""

import json
import os
import sys

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload


def upload_to_gdrive(file_path: str) -> str:
    # サービスアカウント認証
    sa_info = json.loads(os.environ["GDRIVE_SERVICE_ACCOUNT"])
    credentials = service_account.Credentials.from_service_account_info(
        sa_info, scopes=["https://www.googleapis.com/auth/drive.file"]
    )

    service = build("drive", "v3", credentials=credentials)

    file_name = os.path.basename(file_path)
    folder_id = os.environ["GDRIVE_FOLDER_ID"]

    # 同名ファイルが既にあれば更新、なければ新規作成
    query = f"name='{file_name}' and '{folder_id}' in parents and trashed=false"
    results = service.files().list(q=query, fields="files(id)").execute()
    existing = results.get("files", [])

    media = MediaFileUpload(file_path, mimetype="text/markdown")

    if existing:
        # 既存ファイルを更新
        file_id = existing[0]["id"]
        service.files().update(fileId=file_id, media_body=media).execute()
        print(f"Updated: {file_name} (ID: {file_id})")
        return file_id
    else:
        # 新規作成
        file_metadata = {"name": file_name, "parents": [folder_id]}
        created = (
            service.files()
            .create(body=file_metadata, media_body=media, fields="id")
            .execute()
        )
        print(f"Created: {file_name} (ID: {created['id']})")
        return created["id"]


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python upload_to_gdrive.py <file_path>")
        sys.exit(1)

    upload_to_gdrive(sys.argv[1])
