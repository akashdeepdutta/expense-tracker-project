import axios from 'axios';

const API_BASE_URL = '/api/v1';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized access
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Types
export interface Expense {
  id?: number;
  title: string;
  description?: string;
  amount: number;
  currencyCode: string;
  date: string;
  categoryId?: number;
  location?: string;
  tags?: string;
  isReimbursable?: boolean;
  status?: 'PENDING' | 'APPROVED' | 'REJECTED';
  receiptImageUrl?: string;
  ocrData?: string;
}

export interface Category {
  id: number;
  name: string;
  description?: string;
  icon?: string;
  color?: string;
  isDefault?: boolean;
}

export interface ReceiptData {
  merchantName: string;
  totalAmount: number;
  taxAmount: number;
  date: string;
  items: ReceiptItem[];
  ocrText: string;
  confidence: number;
}

export interface ReceiptItem {
  name: string;
  price: number;
  quantity: number;
}

export interface ExpenseStatistics {
  totalSpending: number;
  averageDailySpending: number;
  totalExpenses: number;
  period: {
    startDate: string;
    endDate: string;
  };
}

export interface SpendingByCategory {
  categories: Array<{
    categoryId: number;
    categoryName: string;
    totalAmount: number;
    count: number;
  }>;
  totalAmount: number;
}

// Expense API calls
export const getExpenses = async (params?: {
  page?: number;
  size?: number;
  categoryId?: number;
  startDate?: string;
  endDate?: string;
  currency?: string;
  minAmount?: number;
  maxAmount?: number;
  tags?: string;
}) => {
  const response = await api.get('/expenses', { params });
  return response.data;
};

export const getExpense = async (id: number) => {
  const response = await api.get(`/expenses/${id}`);
  return response.data;
};

export const createExpense = async (expense: Expense) => {
  const response = await api.post('/expenses', expense);
  return response.data;
};

export const updateExpense = async (id: number, expense: Expense) => {
  const response = await api.put(`/expenses/${id}`, expense);
  return response.data;
};

export const deleteExpense = async (id: number) => {
  const response = await api.delete(`/expenses/${id}`);
  return response.data;
};

// Receipt scanning
export const scanReceipt = async (imageBase64: string, imageFormat: string) => {
  const response = await api.post('/expenses/scan-receipt', {
    imageBase64,
    imageFormat,
  });
  return response.data;
};

export const uploadReceipt = async (expenseId: number, imageBase64: string, imageFormat: string) => {
  const response = await api.post(`/expenses/${expenseId}/receipt`, {
    imageBase64,
    imageFormat,
  });
  return response.data;
};

// Analytics
export const getExpenseStatistics = async (startDate?: string, endDate?: string) => {
  const response = await api.get('/expenses/statistics', {
    params: { startDate, endDate },
  });
  return response.data;
};

export const getSpendingByCategory = async (startDate?: string, endDate?: string) => {
  const response = await api.get('/expenses/analytics/spending-by-category', {
    params: { startDate, endDate },
  });
  return response.data;
};

export const getSpendingTrend = async (startDate?: string, endDate?: string) => {
  const response = await api.get('/expenses/analytics/spending-trend', {
    params: { startDate, endDate },
  });
  return response.data;
};

export const getReimbursableExpenses = async () => {
  const response = await api.get('/expenses/reimbursable');
  return response.data;
};

// Category API calls
export const getCategories = async () => {
  const response = await api.get('/categories');
  return response.data;
};

export const createCategory = async (category: Omit<Category, 'id'>) => {
  const response = await api.post('/categories', category);
  return response.data;
};

export const updateCategory = async (id: number, category: Category) => {
  const response = await api.put(`/categories/${id}`, category);
  return response.data;
};

export const deleteCategory = async (id: number) => {
  const response = await api.delete(`/categories/${id}`);
  return response.data;
};

// User API calls
export const getUserProfile = async () => {
  const response = await api.get('/users/profile');
  return response.data;
};

export const updateUserProfile = async (profile: any) => {
  const response = await api.put('/users/profile', profile);
  return response.data;
};

// Auth API calls
export const login = async (username: string, password: string) => {
  const response = await api.post('/auth/login', { username, password });
  return response.data;
};

export const register = async (userData: {
  username: string;
  password: string;
  firstName?: string;
  lastName?: string;
  defaultCurrency?: string;
}) => {
  const response = await api.post('/auth/register', userData);
  return response.data;
};

// Currency API calls
export const getCurrencies = async () => {
  const response = await api.get('/currencies');
  return response.data;
};

// Export functions
export const exportExpenses = async (params?: {
  startDate?: string;
  endDate?: string;
  categoryId?: number;
}) => {
  const response = await api.get('/export/expenses', {
    params,
    responseType: 'blob',
  });
  return response.data;
};

export default api; 