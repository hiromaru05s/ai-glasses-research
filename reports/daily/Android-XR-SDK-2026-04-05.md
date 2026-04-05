# Android XR SDK 最新アップデートレポート

**作成日**: 2026年4月5日
**対象**: Android XR SDK Developer Preview 2 & 3
**言語**: 日本語

---

## 要約

GoogleはAndroid XR SDKの重要なアップデートを連続でリリースしている。**Developer Preview 2（2025年5月）**では動画再生・ハンドトラッキング・UI適応化が追加され、**Developer Preview 3（2025年12月）**ではAIグラス向けの新ライブラリ（Jetpack Projected、Jetpack Compose Glimmer）が導入された。開発への影響としては、①新しいUI設計が必要（特にグラス向けの透過表示対応）、②拡張現実と没入型の2つの異なるパラダイムに対応する必要がある、③ハンドトラッキングと顔認識など新しい入力モードへの対応が重要となる。

---

## 🔴 開発に影響する重要な変更

### 1. AIグラス向け新ライブラリの登場（破壊的ではないが重要）

**Developer Preview 3で新規追加:**

| ライブラリ | 用途 | 開発への影響 |
|-----------|------|-----------|
| **Jetpack Projected** | モバイル←→AIグラス間のセンサー・スピーカー・ディスプレイ共有 | スマホアプリをグラスに拡張する新しい設計パターンが必要 |
| **Jetpack Compose Glimmer** | 光学シースルー表示向けUI設計言語 | Material Design for XRと異なる制約（背景透過、レイヤー構造）を理解する必要がある |

**Hiromaruへの影響**: 現在Compose/Material Designで開発している場合、Glimmerの制約（視認性・最小限の表示・ジェスチャー認識）を後から適用するのは困難。**開発初期段階からグラス向けUIパラダイムを設計に組み込むべき**。

---

### 2. ハンドトラッキング & 顔認識の実装化

**Developer Preview 2以降で実装可能:**

- **ハンドトラッキング**: 26個のポーズ関節点でジェスチャー検出が可能に
- **顔認識**: 68個のフェイスブレンドシェイプ + アイトラッキング + 深度マッピング（DP3）

**開発への影響**: これまで手入力は仮想キーボード・タッチパッドが主流だったが、ジェスチャー認識が標準化されつつある。アプリが「ジェスチャー入力を前提とした設計」か「従来の物理入力に後付け対応」かで開発工数が大きく変わる。

---

### 3. ビデオ & アニメーション対応の拡充

**Developer Preview 2で追加:**
- 180°/360°立体動画再生（MV-HEVC対応）
- Widevine DRM対応
- 空間アニメーション（Jetpack Compose for XR）

**Developer Preview 3で追加:**
- glTF動的ローディング
- マテリアル拡張

**開発への影響**: 動画やアニメーション素材の制作・最適化が重要性を増している。特に立体動画はエンコーディング方式が限定的（MV-HEVC）なため、素材制作ツールチェーンを整備する必要がある。

---

## デバイス対応状況

| デバイス | ステータス | 対応SDK |
|---------|----------|--------|
| **Samsung Galaxy XR** | 2025年発売済み | DP2以降 |
| **XREAL Project Aura** | 2025年デベロッパーエディション発売 | DP2以降 |
| **Google AI Glasses** | 2026年予定（Samsung/Warby Parker/Gentle Monsterとの協力） | DP3準拠予定 |

---

## Hiromaruの開発チームへの具体的なアクション

### [高優先度]

1. **Jetpack Compose Glimmer の調査・プロトタイプ**
   - 現在のCompose実装がGlimmerに対応可能か確認
   - グラス向けレイアウト制約（背景透過・FOV適応）の実装パターンを研究
   - **根拠**: DP3がAIグラス開発を正式にサポートし、Glimmerが標準化されつつあるため、早期の学習が競争優位性につながる

2. **ハンドトラッキング実装の検討**
   - ARCore for Jetpack XRの手ジェスチャーAPI（26関節点）の仕様確認
   - 既存のタッチ/物理入力との共存設計を決定
   - **根拠**: ジェスチャー入力が標準化されると、非対応アプリは UX で劣後する

3. **動画素材ワークフローの最適化**
   - MV-HEVCエンコーディングが実装可能な制作ツール・フレームワークの調査
   - 立体動画テスト用の検証環境構築
   - **根拠**: 没入型体験（Galaxy XR等）では動画品質が重要だが、エンコーディング選択肢が限定的

### [中優先度]

4. **顔認識・アイトラッキング API の検証**
   - Developer Preview 3の顔認識（68フェイスブレンドシェイプ）の精度・応答性を測定
   - プライバシー実装（オンデバイス処理、同意フロー）の設計
   - **根拠**: DP3は実験的機能が多いため、本番対応には検証期間が必要

5. **マルチデバイス対応戦略の再評価**
   - DP2（没入型XR）とDP3（拡張現実AI Glasses）のコード共有可能範囲を特定
   - Jetpack Projected（モバイル←→グラス）の活用パターンを設計
   - **根拠**: 今後、同じコードベースで複数デバイスに展開するのが主流になるため、設計段階での判断が重要

### [参考・監視]

- Google 公式ドキュメント [developer.android.com/xr](https://developer.android.com/develop/xr) の定期確認（月1回程度）
- Android XR Emulator、XR Glasses Emulator の定期アップデート確認
- 2026年Google AI Glasses発表時のSDK動向

---

## 破壊的変更（Breaking Changes）

現在までのところ、DP2→DP3への破壊的変更は報告されていない。ただし**Developer Preview段階**であるため、本番版（1.0）リリースまでにAPI変更の可能性がある。

**推奨**: 定期的に [Get support for the Android XR SDK](https://developer.android.com/develop/xr/support) でリリースノート・マイグレーションガイドを確認すること。

---

## ソース一覧

### 公式ドキュメント・ブログ
- [Updates to the Android XR SDK: Introducing Developer Preview 2](https://android-developers.googleblog.com/2025/05/updates-to-android-xr-sdk-developer-preview.html) — Android Developers Blog (May 2025)
- [Build for AI Glasses with the Android XR SDK Developer Preview 3](https://android-developers.googleblog.com/2025/12/build-for-ai-glasses-with-android-xr.html) — Android Developers Blog (December 2025)
- [Android XR | Android Developers](https://developer.android.com/develop/xr) — 公式デベロッパーサイト
- [Get support for the Android XR SDK](https://developer.android.com/develop/xr/support) — サポート・リリースノート

### 参考記事
- [Android XR SDK Developer Preview 3 Fully Released](https://vrnewstoday.com/en/Android-XR-SDK-Developer-Preview-3-Fully-Released:-Google-Makes-XR-Development-Easier-and-More-Unified/) — VR News Today
- [Google announces Android XR, launching 2025 on Samsung headset](https://9to5google.com/2024/12/12/android-xr-announcement/) — 9to5Google

---

## 補足: 競合製品との比較

| プラットフォーム | グラス対応 | UI設計言語 | 入力方式 | 成熟度 |
|---------------|----------|----------|--------|------|
| **Android XR** | DP3で新規対応（2025年12月） | Glimmer（DP3新規） | タッチパッド・ジェスチャー・音声 | Developer Preview |
| **Meta Spark / Horizon OS** | 既存対応（Ray-Ban Meta等） | 独自フレームワーク | タッチパッド・ジェスチャー・音声 | 本番運用中 |
| **Apple visionOS** | AI Glasses未発表 | SwiftUI + RealityKit | 視線・ハンド・ジェスチャー | 本番運用中（Vision Pro向け） |

**Hiromaruの立場**: Meta Spark（成熟、即座に開発可能）とAndroid XR（新規、中長期の競争優位性）の両面対応を検討する価値あり。特にAndroid XRはGoogleの投資規模が大きく、2026年AI Glasses発表で勢いが加速する見込み。

---

## 次回フォローアップ

- 2026年Q2: Google AI Glasses発表時のSDK仕様確認
- 2026年通年: Android XR SDK 1.0正式版リリース予定時期の確認
- 毎月: [Android Developers Blog](https://android-developers.googleblog.com/) のXR関連記事監視
