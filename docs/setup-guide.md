# インストール・セットアップガイド

## 📋 必要要件

### ソフトウェア要件
- **MetaTrader 5**: 最新版推奨
- **Windows 10/11**: 64bit
- **最小メモリ**: 4GB RAM
- **推奨メモリ**: 8GB以上

### 対応ブローカー
- MQL5対応のFXブローカー
- 低スプレッド推奨（2pips未満）
- ECN口座推奨

## 🚀 インストール手順

### 1. プロジェクトダウンロード

```bash
# GitHubからクローン
git clone https://github.com/ShoCodeNode/mql5_scalping_strategy.git
```

または、ZIPファイルをダウンロードして展開

### 2. MetaTrader 5への配置

1. **MetaTrader 5を起動**
2. **メニュー**: `File` > `Open Data Folder`
3. **MQL5フォルダ**を開く
4. **プロジェクトファイルをコピー**:
   ```
   MQL5/
   ├── Experts/
   │   └── AdaptiveScalpingEA.mq5
   ├── Include/
   │   ├── ScalpingConfig.mqh
   │   ├── RiskManager.mqh
   │   ├── SignalGenerator.mqh
   │   └── TrailingManager.mqh
   └── Scripts/
       └── StrategyTester.mq5
   ```

### 3. コンパイル

1. **MetaTrader 5を再起動**
2. **MetaEditor**を開く
3. **AdaptiveScalpingEA.mq5**を開く
4. **F7キー**または`Compile`ボタンでコンパイル
5. エラーがないことを確認

## ⚙️ 基本設定

### 1. EAの適用

1. **Navigator**から`Expert Advisors`を展開
2. **AdaptiveScalpingEA**をチャートにドラッグ
3. **Allow live trading**にチェック
4. **パラメーター設定**（下記参照）
5. **OK**をクリック

### 2. 推奨パラメーター

#### 基本設定
```
Risk per trade: 1.0%        # 保守的なリスク
Max positions: 1            # 1通貨ペア1ポジション
Max spread: 3.0 pips        # スプレッドフィルター
```

#### 時間フィルター
```
London start: 16 (JST)      # ロンドン開始
London end: 20 (JST)        # ロンドン終了
New York start: 22 (JST)    # ニューヨーク開始  
New York end: 2 (JST)       # ニューヨーク終了
Avoid Friday late: true     # 金曜遅い時間回避
```

#### インジケーター設定
```
EMA Fast: 5
EMA Medium: 10
EMA Slow: 20
RSI Period: 14
RSI Oversold: 30
RSI Overbought: 70
MACD Fast: 12
MACD Slow: 26
MACD Signal: 9
```

#### ATRトレーリング
```
ATR Period: 14
ATR Start Mult: 1.5         # 開始条件
ATR Step Mult: 0.8          # 追従間隔
ATR Min Profit: 0.5         # 最小利益保証
```

## 📊 推奨チャート設定

### 通貨ペア
- **主要ペア**: EUR/USD, GBP/USD, USD/JPY
- **推奨**: EUR/USD（最も安定）

### 時間軸
- **チャート表示**: M1（1分足）
- **EA内部**: M5トレンド確認 + M1エントリー

### チャートテンプレート
```
インジケーター表示（参考用）:
- EMA(5, 10, 20)
- RSI(14)
- MACD(12, 26, 9)
- ATR(14)
```

## 🧪 テスト手順

### 1. ストラテジーテスター

1. **Ctrl+R**でStrategy Testerを開く
2. **Expert Advisor**: AdaptiveScalpingEA
3. **Symbol**: EURUSD
4. **Period**: M1
5. **テスト期間**: 1ヶ月以上推奨
6. **Deposit**: 10,000以上
7. **テスト開始**

### 2. デモ取引

1. **デモ口座**で最低1週間テスト
2. **リアルタイム**での動作確認
3. **パフォーマンス記録**

### 3. パフォーマンス目標

```
目標指標:
- 勝率: 65%以上
- プロフィットファクター: 1.5以上
- 最大ドローダウン: 5%未満
- 月利: 5-15%
```

## ⚠️ 重要な注意事項

### リスク管理
- **必ずデモで検証**してからライブ取引
- **小額資金**から開始
- **損失許容額**を事前に決定
- **感情的な判断**を避ける

### ブローカー選び
- **低スプレッド** (EUR/USD 1pip未満)
- **高速約定**
- **ECN口座**推奨
- **スリッページ最小**

### VPS推奨
- **24時間稼働**のためVPS推奨
- **低レイテンシー**
- **安定した接続**

## 🔧 トラブルシューティング

### コンパイルエラー
```
Error: 'Trade.mqh' file not found
→ MetaTrader 5を最新版に更新
→ MQL5 Wizard経由でファイル生成
```

### 取引されない
```
1. 自動売買が有効か確認
2. 取引時間内か確認  
3. スプレッドが許容範囲内か確認
4. 口座残高が十分か確認
5. ログを確認
```

### パフォーマンス不良
```
1. パラメーター調整
2. 市場環境の変化確認
3. バックテスト再実行
4. 他の通貨ペアでテスト
```

## 📞 サポート

### 問題報告
- **GitHub Issues**: バグ報告・機能要望
- **詳細ログ**を添付
- **設定パラメーター**を記載

### アップデート
- **GitHub**で最新版をチェック
- **変更履歴**を確認
- **段階的アップデート**推奨

---

**⚠️ 免責事項**: FX取引にはリスクが伴います。必ず自己責任で、十分な検証を行ってから使用してください。