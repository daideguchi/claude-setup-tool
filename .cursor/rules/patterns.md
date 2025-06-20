# デザインパターン

## Reactパターン

### コンポーネント合成パターン
```typescript
// 悪い例: モノリシックなコンポーネント
const Modal = ({ title, content, footer, onClose }) => {
  return (
    <div className="modal">
      <div className="header">{title}</div>
      <div className="content">{content}</div>
      <div className="footer">{footer}</div>
    </div>
  );
};

// 良い例: 合成可能なコンポーネント
const Modal = ({ children, onClose }) => (
  <div className="modal">{children}</div>
);

Modal.Header = ({ children }) => (
  <div className="modal-header">{children}</div>
);

Modal.Content = ({ children }) => (
  <div className="modal-content">{children}</div>
);

Modal.Footer = ({ children }) => (
  <div className="modal-footer">{children}</div>
);
```

### カスタムフックパターン
```typescript
// データフェッチング用カスタムフック
const useApiData = <T>(url: string) => {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await fetch(url);
        if (!response.ok) throw new Error('Failed to fetch');
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [url]);

  return { data, loading, error };
};

// フォーム状態管理用カスタムフック
const useFormState = <T extends Record<string, any>>(initialState: T) => {
  const [values, setValues] = useState(initialState);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({});

  const setValue = (name: keyof T, value: any) => {
    setValues(prev => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: undefined }));
    }
  };

  const setError = (name: keyof T, error: string) => {
    setErrors(prev => ({ ...prev, [name]: error }));
  };

  const setTouched = (name: keyof T) => {
    setTouched(prev => ({ ...prev, [name]: true }));
  };

  return {
    values,
    errors,
    touched,
    setValue,
    setError,
    setTouched,
    reset: () => {
      setValues(initialState);
      setErrors({});
      setTouched({});
    }
  };
};
```

### レンダープロップパターン
```typescript
interface RenderProps<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
}

interface DataProviderProps<T> {
  url: string;
  children: (props: RenderProps<T>) => React.ReactNode;
}

const DataProvider = <T,>({ url, children }: DataProviderProps<T>) => {
  const { data, loading, error } = useApiData<T>(url);
  return <>{children({ data, loading, error })}</>;
};

// 使用例
<DataProvider<User[]> url="/api/users">
  {({ data, loading, error }) => {
    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error}</div>;
    return <UserList users={data || []} />;
  }}
</DataProvider>
```

## Next.js特有のパターン

### サーバーコンポーネントパターン
```typescript
// サーバーコンポーネント（デフォルト）
async function ProductList() {
  // サーバーサイドでデータフェッチ
  const products = await getProducts();
  
  return (
    <div>
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  );
}

// クライアントコンポーネント（必要な場合のみ）
'use client';

import { useState } from 'react';

function InteractiveButton() {
  const [count, setCount] = useState(0);
  
  return (
    <button onClick={() => setCount(c => c + 1)}>
      Count: {count}
    </button>
  );
}
```

### 並列データフェッチングパターン
```typescript
// 並列でデータを取得
async function DashboardPage() {
  // Promise.allを使用して並列実行
  const [user, posts, comments] = await Promise.all([
    getUser(),
    getPosts(),
    getComments()
  ]);

  return (
    <div>
      <UserProfile user={user} />
      <PostsList posts={posts} />
      <CommentsList comments={comments} />
    </div>
  );
}
```

### ストリーミングパターン
```typescript
import { Suspense } from 'react';

function BlogPage() {
  return (
    <div>
      <h1>Blog</h1>
      <Suspense fallback={<div>Loading posts...</div>}>
        <Posts />
      </Suspense>
      <Suspense fallback={<div>Loading sidebar...</div>}>
        <Sidebar />
      </Suspense>
    </div>
  );
}
```

## TypeScriptパターン

### 型安全なAPIパターン
```typescript
// API レスポンス型の定義
interface ApiResponse<T> {
  data: T;
  message: string;
  status: 'success' | 'error';
}

// ジェネリック関数で型安全なAPI呼び出し
async function apiCall<T>(
  endpoint: string,
  options?: RequestInit
): Promise<ApiResponse<T>> {
  const response = await fetch(`/api${endpoint}`, {
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    ...options,
  });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  return response.json();
}

// 使用例
const users = await apiCall<User[]>('/users');
const user = await apiCall<User>('/users/1');
```

### 条件付き型パターン
```typescript
// プロパティの条件付き型
type ButtonProps<T extends 'button' | 'link'> = {
  variant: T;
  children: React.ReactNode;
} & (T extends 'button' 
  ? { onClick: () => void } 
  : { href: string }
);

// 使用例
const Button = <T extends 'button' | 'link'>(props: ButtonProps<T>) => {
  if (props.variant === 'button') {
    return <button onClick={props.onClick}>{props.children}</button>;
  }
  return <a href={props.href}>{props.children}</a>;
};
```

## 状態管理パターン

### Reducer + Contextパターン
```typescript
interface AppState {
  user: User | null;
  theme: 'light' | 'dark';
  notifications: Notification[];
}

type AppAction =
  | { type: 'SET_USER'; payload: User | null }
  | { type: 'TOGGLE_THEME' }
  | { type: 'ADD_NOTIFICATION'; payload: Notification }
  | { type: 'REMOVE_NOTIFICATION'; payload: string };

const appReducer = (state: AppState, action: AppAction): AppState => {
  switch (action.type) {
    case 'SET_USER':
      return { ...state, user: action.payload };
    case 'TOGGLE_THEME':
      return { ...state, theme: state.theme === 'light' ? 'dark' : 'light' };
    case 'ADD_NOTIFICATION':
      return { ...state, notifications: [...state.notifications, action.payload] };
    case 'REMOVE_NOTIFICATION':
      return { 
        ...state, 
        notifications: state.notifications.filter(n => n.id !== action.payload) 
      };
    default:
      return state;
  }
};

const AppContext = createContext<{
  state: AppState;
  dispatch: Dispatch<AppAction>;
} | null>(null);

export const useAppContext = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useAppContext must be used within AppProvider');
  }
  return context;
};
```

## エラーハンドリングパターン

### Error Boundaryパターン
```typescript
interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
}

class ErrorBoundary extends Component<
  { children: React.ReactNode; fallback: React.ComponentType<{ error: Error }> },
  ErrorBoundaryState
> {
  constructor(props: any) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError && this.state.error) {
      return <this.props.fallback error={this.state.error} />;
    }

    return this.props.children;
  }
}
```

## パフォーマンスパターン

### メモ化パターン
```typescript
// 重い計算のメモ化
const ExpensiveComponent = memo(({ data }: { data: ComplexData[] }) => {
  const processedData = useMemo(() => {
    return data.map(item => ({
      ...item,
      processed: heavyComputation(item)
    }));
  }, [data]);

  const handleClick = useCallback((id: string) => {
    // クリックハンドラー
  }, []);

  return (
    <div>
      {processedData.map(item => (
        <Item key={item.id} data={item} onClick={handleClick} />
      ))}
    </div>
  );
});
```

### 仮想化パターン
```typescript
// 大きなリストの仮想化
const VirtualizedList = ({ items }: { items: Item[] }) => {
  const [visibleRange, setVisibleRange] = useState({ start: 0, end: 10 });
  
  const visibleItems = useMemo(() => 
    items.slice(visibleRange.start, visibleRange.end),
    [items, visibleRange]
  );

  return (
    <div className="virtual-list">
      {visibleItems.map(item => (
        <ListItem key={item.id} item={item} />
      ))}
    </div>
  );
};
```

**パターンの選択指針**: 
- コンポーネントの再利用性と保守性を最大化
- 型安全性を保ちながら柔軟性を確保
- パフォーマンスとコードの可読性のバランスを考慮