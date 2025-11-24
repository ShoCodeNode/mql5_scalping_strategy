#!/bin/bash
# GitHub Push Commands for MQL5 Scalping Strategy

echo "=== MQL5 Scalping Strategy - GitHub Push ==="
echo ""
echo "手順:"
echo "1. GitHub.com で新しいリポジトリを作成"
echo "   - Repository name: mql5_scalping_strategy"  
echo "   - Description: MQL5 Adaptive Scalping Strategy with ATR-based Trailing Stop"
echo "   - Public repository"
echo ""
echo "2. 以下のコマンドを実行:"
echo ""
echo "git push -u origin main"
echo ""
echo "=== 現在のローカル状態 ==="
git log --oneline -5
echo ""
echo "=== リモート設定 ==="
git remote -v
echo ""
echo "=== ファイル統計 ==="
echo "Total files: $(find . -type f -not -path './.git/*' | wc -l)"
echo "MQL5 files: $(find . -name '*.mq5' -o -name '*.mqh' | wc -l)"
echo "Documentation files: $(find ./docs -name '*.md' 2>/dev/null | wc -l)"
echo ""
echo "準備完了！GitHubでリポジトリを作成してからプッシュしてください。"