# アーキテクチャ決定記録

## 設計原則
- SOLID原則の遵守
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple, Stupid)

## プロジェクト構造
```
src/
├── core/        # コアロジック
├── utils/       # ユーティリティ関数
├── config/      # 設定ファイル
└── scripts/     # 実行スクリプト
```

## 技術選定
- 言語: プロジェクトに応じて選択
- テストフレームワーク: 言語標準のものを使用
- ビルドツール: 最小限の設定で動作するもの