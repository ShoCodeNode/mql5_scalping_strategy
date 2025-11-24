# MQL5 コンパイル検証ガイド

## 📝 概要

このガイドでは、作成したMQL5スキャルピング戦略のコンパイル検証方法を説明します。

## 🔧 事前準備

### 1. MetaTrader 5のインストール
- [MetaQuotes公式サイト](https://www.metatrader5.com/ja/download)からダウンロード
- 最新版のMT5をインストール
- デモ口座を開設（任意のブローカー）

### 2. プロジェクトファイルの配置
```
C:\Users\[ユーザー名]\AppData\Roaming\MetaQuotes\Terminal\[ターミナルID]\MQL5\
├── Experts\
│   └── AdaptiveScalpingEA.mq5
├── Include\
│   ├── ScalpingConfig.mqh
│   ├── RiskManager.mqh
│   ├── SignalGenerator.mqh
│   └── TrailingManager.mqh
└── Scripts\
    ├── CompilationTest.mq5
    └── StrategyTester.mq5
```

## 🚀 コンパイル手順

### 1. MetaEditor起動
1. MetaTrader 5を起動
2. **F4キー**を押すか、メニューから`Tools` > `MetaQuotes Language Editor`
3. MetaEditorが開く

### 2. プロジェクトを開く
1. MetaEditorで`File` > `Open`
2. `AdaptiveScalpingEA.mq5`を選択
3. ファイルが開かれる

### 3. コンパイル実行
1. **F7キー**を押すか、`Compile`ボタンをクリック
2. 下部の`Errors`タブでエラーをチェック
3. 成功すると`0 error(s), 0 warning(s)`と表示

## ✅ 段階別検証

### Phase 1: 構文チェック
```mql5
// CompilationTest.mq5 を最初にコンパイル
// 基本的なMQL5構文が正常に動作するかテスト
```

**期待結果**: エラーなしでコンパイル完了

### Phase 2: 設定ファイル
```mql5
// ScalpingConfig.mqh をコンパイル
// 設定構造体とクラスの定義をチェック
```

**期待結果**: 構造体とクラスが正しく定義される

### Phase 3: 各マネージャー
```mql5
// RiskManager.mqh
// SignalGenerator.mqh  
// TrailingManager.mqh
// 各クラスが独立してコンパイル可能かチェック
```

### Phase 4: メインEA
```mql5
// AdaptiveScalpingEA.mq5
// 全ての依存関係を含めた完全なコンパイル
```

## 🐛 よくあるエラーと対処法

### Error 1: "'Trade.mqh' file not found"
**原因**: MT5の標準ライブラリが見つからない
**対処法**: 
```mql5
// 最新のMT5をインストール
// または、パスを確認
#include <Trade\Trade.mqh>
```

### Error 2: "semicolon expected"
**原因**: セミコロン忘れ
**対処法**: 
```mql5
// 正しい例
return(true);  // セミコロン必須
```

### Error 3: "'CClassName' - unexpected token"
**原因**: クラスが定義されていない
**対処法**: 
```mql5
// インクルードファイルの順序を確認
#include "ScalpingConfig.mqh"  // 設定を最初に
#include "RiskManager.mqh"     // 依存関係に注意
```

### Error 4: "function 'FunctionName' not defined"
**原因**: 関数の前方宣言が必要
**対処法**: 
```mql5
// ヘッダーで前方宣言
bool ProcessSignal(const SignalInfo &signal);
```

## 📊 コンパイル成功の確認

### 1. エラー・警告数
```
Compilation successful.
0 error(s), 0 warning(s)
Compilation time: X ms
```

### 2. .ex5ファイルの生成
- `Experts\AdaptiveScalpingEA.ex5`が作成される
- ファイルサイズが0以上
- 作成時刻が最新

### 3. MT5での認識
```
Navigator > Expert Advisors > AdaptiveScalpingEA
```
上記に表示されることを確認

## 🧪 動作テスト

### 1. パラメーターチェック
```mql5
// EAをチャートにドラッグして設定画面が表示されるか確認
Input Parameters:
- Risk per trade: 1.0%
- Max positions: 1
- EMA Fast: 5
// 等々...
```

### 2. ログ出力テスト
```mql5
// MT5のExpertsタブで初期化メッセージを確認
2025.11.24 XX:XX:XX AdaptiveScalpingEA EURUSD,M1: EA initialized successfully
```

### 3. インジケーター初期化
```
2025.11.24 XX:XX:XX AdaptiveScalpingEA EURUSD,M1: Indicators initialized successfully
```

## 📈 パフォーマンステスト

### Strategy Testerでの検証
1. MT5で`Ctrl+R`
2. Expert: `AdaptiveScalpingEA`
3. Symbol: `EURUSD`
4. Period: `M1`
5. Date range: 1ヶ月
6. `Start`をクリック

### 期待結果
- エラーなく実行完了
- 取引が発生（設定に応じて）
- レポートが生成される

## 🔧 トラブルシューティング

### コンパイルが通らない場合

1. **MT5を最新版に更新**
2. **MQL5 Wizardで新規EA作成して比較**
3. **段階的コンパイル（依存関係順）**
4. **標準的なEAサンプルと比較**

### 実行時エラーの場合

1. **Expertsタブでログ確認**
2. **Journalタブでシステムメッセージ確認**  
3. **デモ口座での動作確認**
4. **パラメーター設定の見直し**

## 📝 チェックリスト

### コンパイル前
- [ ] MT5が最新版
- [ ] 全てのファイルが正しいフォルダに配置
- [ ] ファイルの文字エンコーディングがUTF-8

### コンパイル時
- [ ] エラー数が0
- [ ] 警告数が0または許容範囲内
- [ ] .ex5ファイルが生成される

### コンパイル後  
- [ ] NavigatorでEAが認識される
- [ ] チャートに適用可能
- [ ] パラメーター設定画面が表示される
- [ ] 初期化ログが正常

### 動作確認
- [ ] Strategy Testerで実行可能
- [ ] デモ口座で正常動作
- [ ] ログにエラーメッセージがない

---

このガイドに従って段階的に検証することで、MQL5スキャルピング戦略の品質を確保できます。