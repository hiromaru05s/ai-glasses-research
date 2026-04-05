---
name: glass-market-research
description: "AIグラス・スマートグラス・ARグラス・XRグラス市場に関する調査・レポート生成スキル。WebSearchでデルタ（差分）報告し新規情報のみを抽出する。日次デルタレポート＋隔週サマリーレポートの2モード。Coworkスケジュールで自動実行。「AIグラスの最新情報」「スマートグラス市場を調べて」「Android XRの最新動向」「Ray-Ban Metaの新機能」「XR市場レポートを作って」など、AIグラス・AR・XR・スマートグラスに関連する調査・分析・レポート依頼があった場合は必ずこのスキルを使うこと。"
---

# AIグラス市場シンクタンク — リサーチスキル

## このスキルの目的

AIグラス（スマートグラス/ARグラス/XRグラス）市場を継続的に監視し、事業判断に使えるインテリジェンスを提供する。「Hiromaruが毎朝読んで、チケットを切ったりcoworkerに共有する」ための情報を作る。出力は「次に何をすべきか」が明確なアクションドリブンな文書であること。

---

## 最重要原則

### 1. デルタ報告
毎日繰り返し実行される。過去に報告した情報を再報告しない。「前回以降の新規情報のみ」を含める。新規ゼロの日は正直に「なし」で終了。

### 2. ソースはWebSearch
Cowork標準のWebSearchツールで検索する。MCP不要、APIキー不要。

### 3. 引用元の必須記載
全アイテムに以下を必ず記載する:
- **記事タイトル** + **メディア名** + **URL**
- 例: `「Samsung confirms Android XR glasses for 2026」— Tom's Guide https://www.tomsguide.com/...`
- 引用元がないアイテムはレポートに含めない

### 4. 出力先
全てGitリポジトリ内に保存し、Git pushで管理する。外部ストレージは使わない。
- **日次デルタレポート** → `reports/daily/YYYY-MM-DD.md`
- **隔週サマリーレポート** → `reports/biweekly/YYYY-MM-DD.md`
- **ステートファイル** → `reports/state/known-items.json`

---

## 実行環境

**Coworkスケジュール機能**で自動実行。APIキー不要（Proサブスク内）。

### 使用ツール（全てCowork標準搭載）
- **WebSearch**: 情報収集
- **Read / Write / Edit**: ファイル操作
- **Bash**: Git commit & push

### スケジュール
- **日次デルタレポート**: 毎朝 7:00 JST
- **隔週サマリーレポート**: 毎週月曜 8:00 JST（14日未経過ならスキップ）

---

## デルタ報告メカニズム（全モード共通）

### ステートファイル: `reports/state/known-items.json`

このファイルが本スキルの「記憶」。Gitで管理する。

#### ファイル構造
```json
{
  "schema_version": 3,
  "last_updated": "2026-04-05",
  "last_biweekly": "2026-04-05",
  "items": {
    "<hash>": {
      "title": "情報の要約（50文字以内）",
      "source_name": "メディア名 or サイト名",
      "source_url": "記事URL",
      "first_reported": "2026-04-01",
      "last_seen": "2026-04-05",
      "category": "device | sdk | market | partnership | regulation | other"
    }
  }
}
```

#### ハッシュの生成ルール
- **URLがある場合**: URLのドメイン+パス（クエリパラメータ除外）
- **URLがない場合**: `category + タイトル正規化文字列（小文字、空白除去）`
- 同じトピックの別メディア報道 → 1トピックとしてマージ

#### 初回実行（known-items.jsonが存在しない場合）
1. 空の初期構造で作成
2. 全情報を「新規」として収集・報告
3. 全アイテムを記録

#### 90日パージ
毎回 `last_seen` が90日以上前のアイテムを自動削除。

---

## 調査対象

### デバイスメーカー

**Tier 1（事業に直結）**: Meta（Ray-Ban Meta、Orion）、Google（Android XR、Gemini統合）、Samsung（Galaxy XR）、Apple（Vision Pro、visionOS）

**Tier 2（重要）**: Snap（Spectacles）、Qualcomm（Snapdragon AR）、XREAL、Rokid

**Tier 3（動向監視）**: ByteDance/PICO、Xiaomi、Huawei、TCL/RayNeo、Vuzix、Alibaba（Quark）、その他新興

### 技術・開発者向け情報
Android XR SDK、Meta開発者プラットフォーム、ARCore/Spatial SDK、AI統合（Gemini/Meta AI）、UI/UXフレームワーク、エッジAI

### 市場・業界動向
出荷台数・市場規模予測、新製品発表・リーク、パートナーシップ・M&A、規制・プライバシー、カンファレンス発表

---

## モード1: 日次デルタレポート

### Step 0: ステート読み込み
1. `reports/state/known-items.json` を読む（なければ空で作成）
2. 90日パージ実行
3. 既知アイテム数をログ出力

### Step 1: WebSearchで情報収集

以下のクエリでWebSearchを実行する（6〜10クエリ）。英語で検索、結果は日本語で整理。
`sources.md` があれば先に読んで監視対象を把握する。

```
"smart glasses" OR "AR glasses" OR "AI glasses" news this week
"Ray-Ban Meta" OR "Android XR" OR "Samsung XR" announcement update
"Android XR" SDK OR API OR developer update release
"Apple Vision Pro" OR "visionOS" update news
"Meta Orion" OR "Snap Spectacles" OR "XREAL" smart glasses
smart glasses market shipment forecast partnership acquisition
"Qualcomm" OR "Snapdragon" AR XR glasses chip
```

重要な情報が見つかったらそのトピックで追加の深掘り検索を行う。

### Step 2: デルタフィルタリング
1. 各アイテムのハッシュを生成
2. known-itemsに存在 → `last_seen` を更新、レポートから除外
3. known-itemsに不在 → 新規として採用、known-itemsに追加
4. 新規0件 → 「新規情報なし」テンプレートを使用

### Step 3: 優先度付け（新規のみ）
- 🔴 **速報**: 新デバイス発表、SDK破壊的変更、大型M&A
- 🟡 **注目**: 新機能、市場データ更新、業界動向
- ⚪ **参考**: 噂・リーク、マイナーアップデート

### Step 4: レポート生成

`reports/daily/YYYY-MM-DD.md` に出力する。

#### テンプレート（新規情報あり）

```markdown
# AIグラス市場 日次デルタレポート — YYYY-MM-DD

> **新規アイテム: N件** | 既知スキップ: M件

## 要約
<!-- 最重要ポイント3行。「だから何」まで含める -->

---

## 🔴 速報（新規のみ）
<!-- なければ「本日の新規速報なし」 -->

---

## デバイス・メーカー動向（新規のみ）

### Meta
<!--
各アイテムは必ず以下の形式:
- **[🔴/🟡/⚪] トピック見出し** — 内容の要約
  - 📎 [記事タイトル](URL) — メディア名
-->

### Google / Android XR

### Samsung

### Apple

### その他メーカー

---

## 技術・開発者向け情報（新規のみ）

### SDK・API更新

### AI統合動向

---

## 市場・業界動向（新規のみ）

---

## Hiromaruアクションアイテム

### ①開発R&Dへのチケット候補
<!-- [優先度: 高/中/低] 内容 — 📎 [根拠ソース](URL) -->

### 判断が必要な事項

### coworker共有推奨

---

## ソース一覧
<!-- - [記事タイトル](URL) — メディア名 -->
```

#### テンプレート（新規情報なし）

```markdown
# AIグラス市場 日次デルタレポート — YYYY-MM-DD

> **新規アイテム: 0件** | 既知スキップ: M件

## 結果
本日の調査では、前回レポート以降の新規情報は検出されませんでした。

### 検索実行サマリー
- WebSearch: N件のクエリを実行、全て既知情報

次回レポート: 翌営業日
```

### Step 5: Git commit & push

全ファイルをまとめてcommit & push:
```bash
cd <org-glass-market のパス>
git add reports/state/known-items.json reports/daily/YYYY-MM-DD.md
git diff --cached --quiet || git commit -m "daily: YYYY-MM-DD — N new items" && git push origin main
```

### Step 6: 品質セルフチェック

1. **デルタ原則** — 既知情報が紛れ込んでいないか
2. **全アイテムに引用元** — 記事タイトル + URL + メディア名
3. **推測と事実の区別**
4. **「だから何？」** — 事業影響のない情報はノイズ
5. **アクションアイテムに優先度**

---

## モード2: 隔週サマリーレポート

known-items.jsonの「既知情報」を棚卸しして全体像を俯瞰する。

### 実行条件
`last_biweekly` から14日以上経過していれば実行。未経過ならスキップ。

### Step 0: ステート読み込み
`known-items.json` を読み込み、全件を対象にする。

### Step 1: カテゴリ別整理
device / sdk / market / partnership / regulation / other に分類。

### Step 2: レポート生成

`reports/biweekly/YYYY-MM-DD.md` に出力。

```markdown
# AIグラス市場 隔週サマリー — YYYY-MM-DD

> **蓄積アイテム: N件** | 対象期間: YYYY-MM-DD 〜 YYYY-MM-DD

## エグゼクティブサマリー
<!-- 過去2週間の全体像を5行で -->

---

## デバイス・メーカー動向

### Meta
<!-- 全アイテムを時系列で。各アイテムに 📎 引用元 -->

### Google / Android XR

### Samsung

### Apple

### その他メーカー

---

## 技術・開発者向け情報

---

## 市場・業界動向

---

## パートナーシップ・提携マップ

---

## トレンド分析
<!-- 盛り上がっているトピック / 沈静化しているトピック / 次の2週間の予想 -->
```

### Step 3: Git commit & push
```bash
cd <org-glass-market のパス>
git add reports/state/known-items.json reports/biweekly/YYYY-MM-DD.md
git diff --cached --quiet || git commit -m "biweekly: YYYY-MM-DD — N items summary" && git push origin main
```

### Step 4: ステート更新
`last_biweekly` を今日に更新してからcommit。

---

## 予算管理

- **日次**: Proプランの使用量内で収まるよう検索は最大10クエリ
- **隔週**: 検索なし（known-items整理のみ）なので低負荷
- 情報が少ない日は無理に増やさない

## ファイル構成

```
org-glass-market/
├── CLAUDE.md                     # 組織の憲法
├── sources.md                    # 監視対象ソース一覧
├── skills/daily-research/SKILL.md # このファイル
├── reports/
│   ├── daily/                    # 日次デルタレポート
│   ├── biweekly/                 # 隔週サマリーレポート
│   └── state/known-items.json    # ★ デルタ検知用ステートファイル
└── .gitignore
```
