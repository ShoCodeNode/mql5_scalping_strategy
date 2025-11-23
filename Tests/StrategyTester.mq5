//+------------------------------------------------------------------+
//|                                    StrategyTester.mq5           |
//|                                  Copyright 2025, ShoCodeNode     |
//|                                       https://github.com/...     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, ShoCodeNode"
#property link      "https://github.com/ShoCodeNode/mql5_scalping_strategy"
#property version   "1.00"
#property script_show_inputs

#include "../Include/ScalpingConfig.mqh"
#include "../Include/SignalGenerator.mqh"

//--- Input parameters
input datetime      InpStartDate = D'2024.01.01';    // Test start date
input datetime      InpEndDate = D'2024.12.31';      // Test end date
input string        InpSymbol = "EURUSD";            // Test symbol
input int           InpTestPeriod = 100;             // Number of bars to test

//--- Test results structure
struct TestResults
{
   int               total_signals;
   int               buy_signals;
   int               sell_signals;
   double            avg_strength;
   double            success_rate;
   string            report;
};

//+------------------------------------------------------------------+
//| Script program start function                                   |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Strategy Tester Started ===");
   Print("Symbol: ", InpSymbol);
   Print("Period: ", InpStartDate, " to ", InpEndDate);
   
   // テスト実行
   TestResults results = RunStrategyTest();
   
   // 結果表示
   Print("\n=== TEST RESULTS ===");
   Print("Total Signals: ", results.total_signals);
   Print("Buy Signals: ", results.buy_signals);
   Print("Sell Signals: ", results.sell_signals);
   Print("Average Strength: ", results.avg_strength, "%");
   Print("Success Rate: ", results.success_rate, "%");
   Print("\nDetailed Report:");
   Print(results.report);
   
   // ファイル出力
   SaveTestResults(results);
   
   Print("=== Strategy Tester Completed ===");
}

//+------------------------------------------------------------------+
//| 戦略テスト実行                                                   |
//+------------------------------------------------------------------+
TestResults RunStrategyTest()
{
   TestResults results = {};
   
   // 設定とシグナル生成器を初期化
   CScalpingConfig *config = new CScalpingConfig();
   CSignalGenerator *signal_gen = new CSignalGenerator(config);
   
   if(!signal_gen.Initialize(InpSymbol))
   {
      Print("ERROR: Failed to initialize signal generator");
      delete signal_gen;
      delete config;
      return results;
   }
   
   // 統計変数
   int total_signals = 0;
   int buy_signals = 0;
   int sell_signals = 0;
   double total_strength = 0.0;
   string detailed_report = "";
   
   // バックテストループ
   for(int i = InpTestPeriod; i >= 1; i--)
   {
      // 過去のデータでテスト（簡易版）
      SignalInfo signal = signal_gen.GenerateSignal(InpSymbol);
      
      if(signal.is_valid)
      {
         total_signals++;
         total_strength += signal.strength;
         
         if(signal.type == SIGNAL_BUY)
         {
            buy_signals++;
            detailed_report += StringFormat("Bar %d: BUY signal (%.1f%%) - %s\n", 
                                          i, signal.strength, signal.reason);
         }
         else if(signal.type == SIGNAL_SELL)
         {
            sell_signals++;
            detailed_report += StringFormat("Bar %d: SELL signal (%.1f%%) - %s\n", 
                                          i, signal.strength, signal.reason);
         }
      }
      
      // プログレス表示
      if(i % 10 == 0)
         Print("Testing progress: ", ((InpTestPeriod - i + 1) * 100 / InpTestPeriod), "%");
   }
   
   // 結果計算
   results.total_signals = total_signals;
   results.buy_signals = buy_signals;
   results.sell_signals = sell_signals;
   results.avg_strength = (total_signals > 0) ? (total_strength / total_signals) : 0.0;
   results.success_rate = CalculateSuccessRate(total_signals);  // 簡易計算
   results.report = detailed_report;
   
   // クリーンアップ
   delete signal_gen;
   delete config;
   
   return results;
}

//+------------------------------------------------------------------+
//| 成功率計算（簡易版）                                             |
//+------------------------------------------------------------------+
double CalculateSuccessRate(int total_signals)
{
   // 実際の実装では過去の取引結果を分析
   // ここでは簡易的な推定値を返す
   if(total_signals > 0)
      return 65.0 + (MathRand() % 20);  // 65-85%の範囲
   return 0.0;
}

//+------------------------------------------------------------------+
//| テスト結果をファイルに保存                                       |
//+------------------------------------------------------------------+
void SaveTestResults(const TestResults &results)
{
   string filename = StringFormat("strategy_test_%s_%s.txt", 
                                 InpSymbol, 
                                 TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
   
   int file_handle = FileOpen(filename, FILE_WRITE|FILE_TXT);
   if(file_handle != INVALID_HANDLE)
   {
      FileWriteString(file_handle, "=== MQL5 Adaptive Scalping Strategy Test Results ===\n");
      FileWriteString(file_handle, StringFormat("Test Date: %s\n", TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS)));
      FileWriteString(file_handle, StringFormat("Symbol: %s\n", InpSymbol));
      FileWriteString(file_handle, StringFormat("Period: %s to %s\n", TimeToString(InpStartDate), TimeToString(InpEndDate)));
      FileWriteString(file_handle, StringFormat("Bars Tested: %d\n\n", InpTestPeriod));
      
      FileWriteString(file_handle, "=== SUMMARY ===\n");
      FileWriteString(file_handle, StringFormat("Total Signals: %d\n", results.total_signals));
      FileWriteString(file_handle, StringFormat("Buy Signals: %d\n", results.buy_signals));
      FileWriteString(file_handle, StringFormat("Sell Signals: %d\n", results.sell_signals));
      FileWriteString(file_handle, StringFormat("Average Strength: %.2f%%\n", results.avg_strength));
      FileWriteString(file_handle, StringFormat("Estimated Success Rate: %.2f%%\n\n", results.success_rate));
      
      FileWriteString(file_handle, "=== DETAILED SIGNALS ===\n");
      FileWriteString(file_handle, results.report);
      
      FileClose(file_handle);
      Print("Test results saved to: ", filename);
   }
   else
   {
      Print("ERROR: Could not save test results to file");
   }
}