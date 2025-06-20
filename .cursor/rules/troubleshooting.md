# トラブルシューティング

## Next.js関連の問題

### ハイドレーションエラー
**問題**: サーバーとクライアントの出力が一致しない
```
Warning: Text content did not match. Server: "Server time" Client: "Client time"
```

**解決方法**:
```typescript
// 悪い例: サーバーとクライアントで異なる値
const BadComponent = () => {
  return <div>{new Date().toString()}</div>;
};

// 良い例: useEffectでクライアントサイドのみ実行
const GoodComponent = () => {
  const [mounted, setMounted] = useState(false);
  
  useEffect(() => {
    setMounted(true);
  }, []);
  
  if (!mounted) {
    return <div>Loading...</div>;
  }
  
  return <div>{new Date().toString()}</div>;
};
```

### App Router でのレイアウトエラー
**問題**: レイアウトが期待通りに動作しない

**解決方法**:
```typescript
// 正しいレイアウト構造
// app/layout.tsx (ルートレイアウト)
export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ja">
      <body>{children}</body>
    </html>
  );
}

// app/dashboard/layout.tsx (ネストされたレイアウト)
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="dashboard-layout">
      <nav>Navigation</nav>
      <main>{children}</main>
    </div>
  );
}
```

### Server Actions のエラー
**問題**: 'use server' ディレクティブのエラー

**解決方法**:
```typescript
// server-actions.ts
'use server';

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string;
  // サーバーサイドの処理
}

// コンポーネントで使用
import { createPost } from './server-actions';

export default function PostForm() {
  return (
    <form action={createPost}>
      <input name="title" type="text" />
      <button type="submit">Submit</button>
    </form>
  );
}
```

## TypeScript関連の問題

### 型エラーの解決

#### 'any' 型の問題
**問題**: TypeScriptの厳格さを回避するため 'any' を使用
```typescript
// 悪い例
const data: any = fetchData();

// 良い例: 適切な型定義
interface User {
  id: string;
  name: string;
  email: string;
}

const data: User = await fetchData();

// unknown型を使用してより安全に
const data: unknown = await fetchData();
if (isUser(data)) {
  // type guard を使用
  console.log(data.name);
}

function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'name' in obj &&
    'email' in obj
  );
}
```

#### インポートエラーの解決
**問題**: モジュールが見つからないエラー
```
Cannot find module '@/components/Button'
```

**解決方法**:
```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/lib/*": ["./src/lib/*"]
    }
  }
}
```

#### Tailwind CSSとTypeScript
**問題**: Tailwindクラスの型チェック
```typescript
// 型安全なクラス名ヘルパー
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// 使用例
const Button = ({ className, ...props }: ButtonProps) => {
  return (
    <button
      className={cn(
        'px-4 py-2 rounded-md bg-blue-500 text-white',
        className
      )}
      {...props}
    />
  );
};
```

## React関連の問題

### useEffect の無限ループ
**問題**: useEffectが無限に実行される
```typescript
// 悪い例: 依存配列に問題がある
useEffect(() => {
  setData(expensiveComputation());
}, [data]); // dataが更新されるたびに実行される

// 良い例: 適切な依存配列
useEffect(() => {
  const result = expensiveComputation(input);
  setData(result);
}, [input]); // inputが変更された時のみ実行

// メモ化を使用した解決
const memoizedData = useMemo(() => {
  return expensiveComputation(input);
}, [input]);
```

### State更新の問題
**問題**: 非同期処理での状態更新
```typescript
// 悪い例: 古い状態を参照
const [count, setCount] = useState(0);

const handleClick = () => {
  setTimeout(() => {
    setCount(count + 1); // 古いcountを参照
  }, 1000);
};

// 良い例: 関数的更新を使用
const handleClick = () => {
  setTimeout(() => {
    setCount(prev => prev + 1); // 最新の状態を取得
  }, 1000);
};
```

### メモリリークの防止
**問題**: コンポーネントアンマウント後のstate更新
```typescript
// 悪い例: メモリリークの可能性
useEffect(() => {
  fetchData().then(data => {
    setData(data); // コンポーネントがアンマウントされている可能性
  });
}, []);

// 良い例: クリーンアップ関数を使用
useEffect(() => {
  let cancelled = false;
  
  fetchData().then(data => {
    if (!cancelled) {
      setData(data);
    }
  });
  
  return () => {
    cancelled = true;
  };
}, []);

// AbortControllerを使用したより良い解決法
useEffect(() => {
  const controller = new AbortController();
  
  fetchData({ signal: controller.signal })
    .then(data => setData(data))
    .catch(error => {
      if (error.name !== 'AbortError') {
        console.error(error);
      }
    });
  
  return () => {
    controller.abort();
  };
}, []);
```

## パフォーマンス問題

### 重いレンダリングの最適化
**問題**: コンポーネントの再レンダリングが頻繁

**解決方法**:
```typescript
// React.memoを使用
const ExpensiveComponent = memo(({ data }: Props) => {
  return <div>{/* 重い処理 */}</div>;
});

// カスタム比較関数
const ExpensiveComponent = memo(({ data }: Props) => {
  return <div>{/* 重い処理 */}</div>;
}, (prevProps, nextProps) => {
  return prevProps.data.id === nextProps.data.id;
});

// useCallbackでコールバック関数を最適化
const Parent = () => {
  const [count, setCount] = useState(0);
  
  const handleClick = useCallback(() => {
    // 何らかの処理
  }, []); // 依存配列が空なので関数は再作成されない
  
  return <Child onClick={handleClick} />;
};
```

### バンドルサイズの問題
**問題**: JavaScriptバンドルが大きすぎる

**解決方法**:
```typescript
// 動的インポートを使用
const LazyComponent = lazy(() => import('./LazyComponent'));

// ライブラリの一部のみインポート
import { debounce } from 'lodash'; // 悪い例: 全体をインポート
import debounce from 'lodash/debounce'; // 良い例: 必要な部分のみ

// Next.js での動的インポート
const DynamicComponent = dynamic(() => import('./Component'), {
  loading: () => <p>Loading...</p>,
  ssr: false, // SSRを無効化（必要に応じて）
});
```

## デバッグ技法

### React Developer Tools の活用
```typescript
// コンポーネントにdisplayNameを設定
const MyComponent = () => {
  return <div>Content</div>;
};
MyComponent.displayName = 'MyComponent';

// カスタムフックのデバッグ
const useCustomHook = () => {
  const [state, setState] = useState(0);
  
  // デバッグ用の情報を追加
  useDebugValue(state > 0 ? 'Positive' : 'Zero or Negative');
  
  return [state, setState];
};
```

### エラー境界の実装
```typescript
class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // エラーレポートサービスに送信
    console.error('Error caught:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }

    return this.props.children;
  }
}
```

## 開発環境の問題

### ESLint/Prettier設定の競合
**問題**: ESLintとPrettierのルールが競合

**解決方法**:
```json
// .eslintrc.json
{
  "extends": [
    "next/core-web-vitals",
    "prettier" // prettierは最後に配置
  ],
  "rules": {
    "prettier/prettier": "error"
  }
}

// prettier.config.js
module.exports = {
  semi: true,
  singleQuote: true,
  tabWidth: 2,
  trailingComma: 'es5',
};
```

### Hot Reload の問題
**問題**: 開発中に変更が反映されない

**解決方法**:
```javascript
// next.config.js
module.exports = {
  experimental: {
    // Fast Refreshを有効化
    fastRefresh: true,
  },
  // ファイル監視の設定
  webpack: (config, { dev }) => {
    if (dev) {
      config.watchOptions = {
        poll: 1000,
        aggregateTimeout: 300,
      };
    }
    return config;
  },
};
```

**トラブルシューティングの基本原則**:
1. エラーメッセージを詳しく読む
2. 段階的に問題を分離する
3. ブラウザの開発者ツールを活用
4. コンソールログとデバッガーを使用
5. 最小再現例を作成する