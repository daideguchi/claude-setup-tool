# コーディング規約

## TypeScript

### 基本ルール
- 厳格TypeScriptを使用し、適切な型定義を行う
- オブジェクト定義にはtypeよりinterfaceを優先
- 再利用可能なコンポーネントにはジェネリック型を使用
- 関数の戻り値の型を必ず定義
- 適切な場所で`const assertions`を使用
- `any`型を回避、適切な型または`unknown`を使用

### 命名規則
- Reactコンポーネント: PascalCase
- 関数や変数: camelCase
- 定数: SCREAMING_SNAKE_CASE
- ファイル名: kebab-case（コンポーネントは除く）
- 説明的で意味のある名前を使用

## Reactベストプラクティス

### コンポーネント開発
- 関数コンポーネントとhooksを使用
- 継承よりコンポジションを優先
- 必要に応じて`React.memo()`でパフォーマンス最適化
- 適切なエラーバウンダリを実装
- 不要な再レンダリング防止のため`useCallback`と`useMemo`を適切に使用
- hooksのルールを厳密に遵守

### 状態管理
- シンプルなローカル状態にuseStateを使用
- 複雑な状態ロジックにuseReducerを使用
- 適切な状態の持ち上げを実装
- アプリ全体の状態にコンテキストを使用
- prop drillingを回避

## Next.js 14 App Router

### 基本原則
- デフォルトでServer Componentsを使用
- クライアントサイド機能が必要な場合のみ`'use client'`ディレクティブを追加
- 新しい`app/`ディレクトリ構造を活用
- 適切なloading、error、not-foundページを使用
- metadata APIで適切なSEOを実装
- コード分割のため動的インポートを使用

### ファイル組織
- 機能ベースのフォルダで関連ファイルをグループ化
- クリーンなインポートのためindexファイルを使用
- 共有ユーティリティは`lib/`ディレクトリに配置
- コンポーネントはアトミックで集中的に
- UIコンポーネントとビジネスロジックを分離

## アクセシビリティ

### 必須要件
- 適切なARIA属性を実装
- キーボードナビゲーションが機能することを確認
- セマンティックHTML要素を使用
- 適切なフォーカス管理を提供
- 適切な色のコントラストを実装
- 画像に適切なaltテキストを追加
- 適切な見出し階層を使用

## パフォーマンス最適化

### 一般的な最適化
- コード分割に`React.lazy()`を使用
- Next.js Imageコンポーネントで適切な画像最適化を実装
- 適切なキャッシュ戦略を使用
- バンドルサイズを最小化
- 適切なローディング状態を実装

### レンダリング最適化
- 不要な再レンダリングを回避
- hooksで適切な依存配列を使用
- 適切なメモ化を実装
- Suspenseバウンダリを適切に使用

## セキュリティ

### ベストプラクティス
- ユーザー入力をサニタイズ
- 適切なCSPヘッダーを実装
- 本番環境でHTTPSを使用
- クライアントとサーバーの両方でデータを検証
- 適切な認証を実装

## エラーハンドリング

### 実装
- Reactエラーにエラーバウンダリを使用
- 適切なtry-catchブロックを実装
- 意味のあるエラーメッセージを提供
- エラーを適切にログ記録
- 失敗した機能の為のグレースフルデグラデーション

## コード品質

### 開発ワークフロー
- ESLintとPrettierを一貫して使用
- 適切なpre-commitフックを実装
- 意味のあるコミットメッセージを書く
- 適切なブランチ戦略を使用
- コードを徹底的にレビュー

### ドキュメンテーション
- コンポーネントの明確なドキュメンテーションを書く
- 複雑なビジネスロジックを文書化
- 最新のREADMEを維持
- 関数にJSDocコメントを使用
- APIエンドポイントを文書化

**必ず優先すべきこと**: コードの可読性、保守性、ユーザーエクスペリエンス。自己文書化されたコードを書き、確立されたパターンに従う。