# 依存関係管理

## Next.js 14 プロジェクト推奨依存関係

### 核となる依存関係
```json
{
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "typescript": "^5.0.0"
  }
}
```

### 推奨ライブラリ

#### スタイリング
```bash
# Tailwind CSS (推奨)
npm install tailwindcss postcss autoprefixer
npm install @tailwindcss/typography @tailwindcss/forms

# クラス名ユーティリティ
npm install clsx tailwind-merge

# アイコン
npm install lucide-react
# または
npm install @heroicons/react
```

#### UI コンポーネント
```bash
# Radix UI (headless components)
npm install @radix-ui/react-dialog
npm install @radix-ui/react-dropdown-menu
npm install @radix-ui/react-select
npm install @radix-ui/react-toast

# または shadcn/ui (推奨)
npx shadcn-ui@latest init
```

#### フォーム管理
```bash
# React Hook Form (推奨)
npm install react-hook-form @hookform/resolvers

# バリデーション
npm install zod
```

#### 状態管理
```bash
# 小〜中規模プロジェクト: React Context + useReducer

# 大規模プロジェクト
npm install zustand
# または
npm install @reduxjs/toolkit react-redux
```

#### アニメーション
```bash
# Framer Motion (推奨)
npm install framer-motion

# CSS-in-JS アニメーション
npm install @emotion/react @emotion/styled
```

#### 日付・時間
```bash
npm install date-fns
# または
npm install dayjs
```

#### HTTP クライアント
```bash
# Server Components では fetch を使用

# Client Components での高度なデータフェッチング
npm install @tanstack/react-query
npm install axios # または標準のfetch
```

#### 開発ツール
```bash
# ESLint & Prettier
npm install --save-dev eslint prettier
npm install --save-dev @typescript-eslint/eslint-plugin
npm install --save-dev eslint-config-prettier

# Husky (Git hooks)
npm install --save-dev husky lint-staged

# テスト
npm install --save-dev jest @testing-library/react
npm install --save-dev @testing-library/jest-dom
```

## 依存関係の管理原則

### 追加基準
1. **必要性の評価**
   - 既存の機能で代替可能か検討
   - バンドルサイズへの影響を評価
   - メンテナンス状況を確認

2. **ライブラリ選定基準**
   ```typescript
   // 良い例: 軽量で型安全なライブラリ
   import { format } from 'date-fns';
   import { z } from 'zod';
   
   // 避ける例: 重いライブラリの全体インポート
   import moment from 'moment'; // date-fnsを推奨
   import _ from 'lodash'; // 必要な関数のみインポート
   ```

3. **TypeScript サポート**
   - 型定義が含まれているか確認
   - `@types/` パッケージの必要性を確認

### バージョン管理戦略

#### セマンティックバージョニング
```json
{
  "dependencies": {
    "react": "^18.2.0",        // マイナーアップデート許可
    "next": "~14.0.3",         // パッチアップデートのみ
    "typescript": "5.2.2"      // 固定バージョン（重要な依存関係）
  }
}
```

#### 定期更新プロセス
```bash
# 依存関係の確認
npm outdated

# セキュリティ脆弱性チェック
npm audit

# 自動修正
npm audit fix

# 依存関係の更新
npm update

# 手動での個別更新
npm install package@latest
```

### 依存関係の分類

#### コア依存関係（慎重に管理）
- React, Next.js, TypeScript
- 主要なUI/状態管理ライブラリ
- ビルドツール関連

#### 開発依存関係
```json
{
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/react": "^18.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0",
    "tailwindcss": "^3.0.0",
    "typescript": "^5.0.0"
  }
}
```

#### ピア依存関係の管理
```bash
# ピア依存関係の警告を確認
npm ls --depth=0

# 必要に応じて手動インストール
npm install react-dom # peerDependency として必要
```

## セキュリティ管理

### 脆弱性対応
```bash
# 定期的なセキュリティチェック
npm audit

# 自動修正（慎重に）
npm audit fix

# 手動対応が必要な場合
npm audit fix --force
```

### ライセンス管理
```bash
# ライセンス確認
npm install -g license-checker
license-checker --summary
```

### 信頼できるソース
- npm公式レジストリのみ使用
- 人気度とメンテナンス状況を確認
- GitHubスター数とイシュー対応状況を評価

## パフォーマンス最適化

### バンドルサイズの監視
```bash
# Next.js Bundle Analyzer
npm install --save-dev @next/bundle-analyzer

# webpack-bundle-analyzer
npm install --save-dev webpack-bundle-analyzer
```

### Tree Shaking の活用
```typescript
// 良い例: 必要な部分のみインポート
import { debounce } from 'lodash/debounce';
import { format, parseISO } from 'date-fns';

// 悪い例: 全体をインポート
import _ from 'lodash';
import * as dateFns from 'date-fns';
```

### 動的インポート
```typescript
// 重いライブラリの遅延読み込み
const Chart = dynamic(() => import('react-chartjs-2'), {
  ssr: false,
  loading: () => <div>Loading chart...</div>
});

// 条件付き読み込み
const loadChartLibrary = async () => {
  if (typeof window !== 'undefined') {
    const { Chart } = await import('chart.js');
    return Chart;
  }
};
```

## 推奨しないライブラリ

### 避けるべきライブラリ
```bash
# 重い/古いライブラリ
moment.js          # → date-fns または dayjs
jquery             # → ネイティブDOM API
bootstrap          # → Tailwind CSS
styled-components  # → Tailwind CSS または CSS Modules
```

### Next.js 14 で非推奨
```bash
# App Router では使用不可/非推奨
next/head          # → metadata API
getStaticProps     # → fetch in Server Components
getServerSideProps # → fetch in Server Components
```

## 依存関係のベストプラクティス

### package.json の整理
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build", 
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:watch": "jest --watch"
  },
  "dependencies": {
    // 本番で必要な依存関係のみ
  },
  "devDependencies": {
    // 開発・ビルド時にのみ必要
  }
}
```

### lockファイルの管理
- `package-lock.json` または `yarn.lock` を必ずコミット
- チーム全体で同じパッケージマネージャーを使用
- CI/CD では `npm ci` を使用

### 定期的なメンテナンス
1. 月次での依存関係更新確認
2. セキュリティアラートの即座対応
3. 不要な依存関係の削除
4. バンドルサイズの定期監視

**依存関係管理の原則**: 必要最小限の依存関係で、定期的な更新とセキュリティ対応を行い、パフォーマンスへの影響を常に意識する。