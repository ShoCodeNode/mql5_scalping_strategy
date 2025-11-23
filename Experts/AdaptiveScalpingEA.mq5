//+------------------------------------------------------------------+
//|                                   AdaptiveScalpingEA.mq5        |
//|                                  Copyright 2025, ShoCodeNode     |
//|                                       https://github.com/...     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, ShoCodeNode"
#property link      "https://github.com/ShoCodeNode/mql5_scalping_strategy"
#property version   "1.00"
#property description "ATR-based Adaptive Scalping EA with Multi-Timeframe Analysis"

#include <Trade\Trade.mqh>
#include "Include\ScalpingConfig.mqh"
#include "Include\RiskManager.mqh"
#include "Include\SignalGenerator.mqh"
#include "Include\TrailingManager.mqh"

//--- Input parameters
input group "=== Basic Settings ==="
input double            InpRiskPercent = 1.0;           // Risk per trade (%)
input int               InpMaxPositions = 1;            // Max positions per pair
input double            InpMaxSpreadPips = 3.0;         // Max spread (pips)

input group "=== Time Filter ==="
input int               InpLondonStart = 16;            // London session start (JST)
input int               InpLondonEnd = 20;              // London session end (JST)
input int               InpNewYorkStart = 22;           // New York session start (JST)
input int               InpNewYorkEnd = 2;              // New York session end (JST)
input bool              InpAvoidFridayLate = true;      // Avoid Friday late trading

input group "=== EMA Settings ==="
input int               InpEMAFast = 5;                 // Fast EMA period
input int               InpEMAMedium = 10;              // Medium EMA period
input int               InpEMASlow = 20;                // Slow EMA period

input group "=== RSI Settings ==="
input int               InpRSIPeriod = 14;              // RSI period
input double            InpRSIOversold = 30.0;          // RSI oversold level
input double            InpRSIOverbought = 70.0;        // RSI overbought level

input group "=== MACD Settings ==="
input int               InpMACDFast = 12;               // MACD fast EMA
input int               InpMACDSlow = 26;               // MACD slow EMA
input int               InpMACDSignal = 9;              // MACD signal SMA

input group "=== ATR Trailing Settings ==="
input int               InpATRPeriod = 14;              // ATR period
input double            InpATRStartMult = 1.5;          // Trailing start multiplier
input double            InpATRStepMult = 0.8;           // Trailing step multiplier
input double            InpATRMinProfitMult = 0.5;      // Min profit multiplier

input group "=== Stop Loss & Take Profit ==="
input double            InpStopLossPips = 10.0;         // Initial stop loss (pips)
input double            InpTakeProfitPips = 15.0;       // Initial take profit (pips)

input group "=== Advanced Settings ==="
input bool              InpUseTrailing = true;          // Enable trailing stop
input bool              InpUsePriceAction = true;       // Use price action filter
input int               InpMagicNumber = 20251124;      // Magic number
input string            InpEAComment = "AdaptiveScalping";  // EA comment

//--- Global variables
CTrade              trade;
CScalpingConfig     *config;
CRiskManager        *risk_manager;
CSignalGenerator    *signal_generator;
CTrailingManager    *trailing_manager;

datetime            last_signal_time = 0;
int                 signal_cooldown_seconds = 10;   // 10秒のクールダウン

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("=== Adaptive Scalping EA v1.0 Initialization ===");
   
   // 取引設定
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(Symbol());
   
   // 設定クラス初期化
   config = new CScalpingConfig();
   ApplyInputParameters();
   
   // 各マネージャー初期化
   risk_manager = new CRiskManager(config);
   signal_generator = new CSignalGenerator(config);
   trailing_manager = new CTrailingManager(config);
   
   // インジケーター初期化
   if(!signal_generator.Initialize(Symbol()))
   {
      Print("ERROR: Failed to initialize signal generator");
      return INIT_FAILED;
   }
   
   trailing_manager.Initialize(Symbol());
   
   // 通貨ペア確認
   if(!config.IsValidSymbol(Symbol()))
   {
      Print("WARNING: ", Symbol(), " is not in the recommended currency pairs list");
   }
   
   Print("EA initialized successfully for ", Symbol());
   Print("Risk per trade: ", config.GetRiskPercent(), "%");
   Print("Max positions per pair: ", config.GetMaxPositions());
   Print("Trading sessions: London(", InpLondonStart, "-", InpLondonEnd, "), NY(", InpNewYorkStart, "-", InpNewYorkEnd, ")");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("=== Adaptive Scalping EA Deinitialization ===");
   Print("Reason: ", reason);
   
   // オブジェクト削除
   if(CheckPointer(trailing_manager) != POINTER_INVALID)
      delete trailing_manager;
   if(CheckPointer(signal_generator) != POINTER_INVALID)
      delete signal_generator;
   if(CheckPointer(risk_manager) != POINTER_INVALID)
      delete risk_manager;
   if(CheckPointer(config) != POINTER_INVALID)
      delete config;
   
   Print("EA deinitialized successfully");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // 基本チェック
   if(!IsNewBar()) return;
   
   // 取引時間チェック
   if(!config.IsTradingTime())
      return;
   
   // 口座状態チェック
   if(!risk_manager.CanOpenPosition(Symbol()))
      return;
   
   // シグナル生成（クールダウン適用）
   if(TimeCurrent() - last_signal_time < signal_cooldown_seconds)
      return;
   
   SignalInfo signal = signal_generator.GenerateSignal(Symbol());
   
   if(signal.is_valid && signal.strength >= 80.0)  // 80%以上の強度で取引
   {
      ProcessSignal(signal);
      last_signal_time = TimeCurrent();
   }
   
   // トレーリングストップ更新
   if(InpUseTrailing)
      trailing_manager.UpdateAllPositions();
}

//+------------------------------------------------------------------+
//| シグナル処理                                                     |
//+------------------------------------------------------------------+
void ProcessSignal(const SignalInfo &signal)
{
   // ロットサイズ計算
   double stop_loss_pips = MathAbs(signal.entry_price - signal.stop_loss) / 
                          ((StringFind(Symbol(), "JPY") > 0) ? 0.01 : 0.0001);
   
   double lot_size = risk_manager.CalculateLotSize(stop_loss_pips);
   if(lot_size <= 0)
   {
      Print("Cannot calculate lot size for signal");
      return;
   }
   
   // オーダー送信
   bool result = false;
   ulong ticket = 0;
   
   if(signal.type == SIGNAL_BUY)
   {
      result = trade.Buy(lot_size, Symbol(), signal.entry_price, 
                        signal.stop_loss, signal.take_profit, 
                        StringFormat("%s Buy %.1f%%", InpEAComment, signal.strength));
      ticket = trade.ResultOrder();
   }
   else if(signal.type == SIGNAL_SELL)
   {
      result = trade.Sell(lot_size, Symbol(), signal.entry_price, 
                         signal.stop_loss, signal.take_profit, 
                         StringFormat("%s Sell %.1f%%", InpEAComment, signal.strength));
      ticket = trade.ResultOrder();
   }
   
   if(result)
   {
      Print("=== ORDER OPENED ===");
      Print("Signal: ", (signal.type == SIGNAL_BUY) ? "BUY" : "SELL");
      Print("Ticket: ", ticket);
      Print("Lot Size: ", lot_size);
      Print("Entry: ", signal.entry_price);
      Print("Stop Loss: ", signal.stop_loss);
      Print("Take Profit: ", signal.take_profit);
      Print("Strength: ", signal.strength, "%");
      Print("Reason: ", signal.reason);
      
      // トレーリング管理に追加
      if(InpUseTrailing && ticket > 0)
      {
         // ポジション確認後追加（注文→ポジション変換待ち）
         Sleep(1000);
         for(int i = 0; i < PositionsTotal(); i++)
         {
            if(PositionGetSymbol(i) == Symbol() && 
               PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
            {
               ulong pos_ticket = PositionGetTicket(i);
               trailing_manager.AddPosition(pos_ticket);
               break;
            }
         }
      }
   }
   else
   {
      Print("ERROR: Failed to open position");
      Print("Error code: ", trade.ResultRetcode());
      Print("Error description: ", trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| 新しいバーかチェック                                             |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   static datetime last_bar_time = 0;
   datetime current_bar_time = iTime(Symbol(), PERIOD_M1, 0);
   
   if(current_bar_time != last_bar_time)
   {
      last_bar_time = current_bar_time;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| 入力パラメーター適用                                             |
//+------------------------------------------------------------------+
void ApplyInputParameters()
{
   config.SetRiskPercent(InpRiskPercent);
   config.SetMaxPositions(InpMaxPositions);
   config.SetMaxSpread(InpMaxSpreadPips);
   
   // 詳細設定は直接構造体にアクセス
   // 実際の実装では設定メソッドを追加することを推奨
}

//+------------------------------------------------------------------+
//| Trade transaction function                                       |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                       const MqlTradeRequest &request,
                       const MqlTradeResult &result)
{
   // ポジションクローズ時の処理
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      if(HistoryDealSelect(trans.deal))
      {
         long deal_type = HistoryDealGetInteger(trans.deal, DEAL_TYPE);
         long deal_magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
         
         if(deal_magic == InpMagicNumber && 
            (deal_type == DEAL_TYPE_BUY || deal_type == DEAL_TYPE_SELL))
         {
            ulong position_id = HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);
            
            // クローズ時の統計
            double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);
            string symbol = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
            
            Print("=== POSITION CLOSED ===");
            Print("Position ID: ", position_id);
            Print("Symbol: ", symbol);
            Print("Profit: ", profit);
            Print("Daily P&L: ", risk_manager.GetDailyPnL());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Timer function (optional)                                       |
//+------------------------------------------------------------------+
void OnTimer()
{
   // 定期的な口座健全性チェックやレポート生成
   static datetime last_report_time = 0;
   
   if(TimeCurrent() - last_report_time > 3600) // 1時間ごと
   {
      Print(risk_manager.GetRiskReport());
      Print(trailing_manager.GetTrailingReport());
      last_report_time = TimeCurrent();
   }
}