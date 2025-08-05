import React from 'react';
import { useQuery } from 'react-query';
import { Link } from 'react-router-dom';
import { 
  Plus, 
  Camera, 
  TrendingUp, 
  DollarSign, 
  Calendar,
  Receipt,
  AlertCircle
} from 'lucide-react';
import { format } from 'date-fns';
import { getExpenseStatistics, getSpendingByCategory } from '../services/api';
import { Doughnut, Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
);

const Dashboard: React.FC = () => {
  const { data: statistics, isLoading: statsLoading } = useQuery(
    'expenseStatistics',
    () => getExpenseStatistics()
  );

  const { data: categoryData, isLoading: categoryLoading } = useQuery(
    'spendingByCategory',
    () => getSpendingByCategory()
  );

  const quickActions = [
    {
      title: 'Add Expense',
      description: 'Manually add a new expense',
      icon: Plus,
      href: '/add-expense',
      color: 'bg-blue-500'
    },
    {
      title: 'Scan Receipt',
      description: 'Scan receipt to extract data',
      icon: Camera,
      href: '/scan-receipt',
      color: 'bg-green-500'
    },
    {
      title: 'View Analytics',
      description: 'Detailed spending analysis',
      icon: TrendingUp,
      href: '/analytics',
      color: 'bg-purple-500'
    }
  ];

  const chartData = {
    labels: categoryData?.categories?.map((cat: any) => cat.categoryName) || [],
    datasets: [
      {
        data: categoryData?.categories?.map((cat: any) => cat.totalAmount) || [],
        backgroundColor: [
          '#FF6B6B',
          '#4ECDC4',
          '#45B7D1',
          '#96CEB4',
          '#FFEAA7',
          '#DDA0DD',
          '#98D8C8',
          '#F7DC6F'
        ],
        borderWidth: 2,
        borderColor: '#fff'
      }
    ]
  };

  const chartOptions = {
    responsive: true,
    plugins: {
      legend: {
        position: 'bottom' as const,
      },
      title: {
        display: true,
        text: 'Spending by Category'
      }
    }
  };

  if (statsLoading || categoryLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600">Welcome back! Here's your expense overview.</p>
        </div>
        <div className="text-right">
          <p className="text-sm text-gray-500">Last updated</p>
          <p className="text-sm font-medium">{format(new Date(), 'MMM dd, yyyy HH:mm')}</p>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {quickActions.map((action) => (
          <Link
            key={action.title}
            to={action.href}
            className="block p-6 bg-white rounded-lg shadow-sm border border-gray-200 hover:shadow-md transition-shadow"
          >
            <div className="flex items-center space-x-4">
              <div className={`p-3 rounded-lg ${action.color} text-white`}>
                <action.icon className="w-6 h-6" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">{action.title}</h3>
                <p className="text-sm text-gray-600">{action.description}</p>
              </div>
            </div>
          </Link>
        ))}
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-blue-100 text-blue-600">
              <DollarSign className="w-6 h-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Spending</p>
              <p className="text-2xl font-bold text-gray-900">
                ${statistics?.totalSpending?.toFixed(2) || '0.00'}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-green-100 text-green-600">
              <Calendar className="w-6 h-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Expenses</p>
              <p className="text-2xl font-bold text-gray-900">
                {statistics?.totalExpenses || 0}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-purple-100 text-purple-600">
              <TrendingUp className="w-6 h-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Daily Average</p>
              <p className="text-2xl font-bold text-gray-900">
                ${statistics?.averageDailySpending?.toFixed(2) || '0.00'}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-orange-100 text-orange-600">
              <Receipt className="w-6 h-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">With Receipts</p>
              <p className="text-2xl font-bold text-gray-900">
                {/* TODO: Add receipt count */}
                12
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Spending by Category</h3>
          <div className="h-64">
            <Doughnut data={chartData} options={chartOptions} />
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h3>
          <div className="space-y-4">
            {/* TODO: Add recent expenses list */}
            <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
              <div className="w-2 h-2 bg-green-500 rounded-full"></div>
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900">Coffee Shop</p>
                <p className="text-xs text-gray-500">$4.50 • 2 hours ago</p>
              </div>
              <span className="text-sm font-medium text-gray-900">$4.50</span>
            </div>
            
            <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
              <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900">Gas Station</p>
                <p className="text-xs text-gray-500">$45.00 • 5 hours ago</p>
              </div>
              <span className="text-sm font-medium text-gray-900">$45.00</span>
            </div>
          </div>
        </div>
      </div>

      {/* Budget Alerts */}
      <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
        <div className="flex items-center space-x-3 mb-4">
          <AlertCircle className="w-5 h-5 text-orange-500" />
          <h3 className="text-lg font-semibold text-gray-900">Budget Alerts</h3>
        </div>
        <div className="space-y-3">
          <div className="flex items-center justify-between p-3 bg-orange-50 rounded-lg">
            <div>
              <p className="text-sm font-medium text-orange-900">Food & Dining</p>
              <p className="text-xs text-orange-700">80% of monthly budget used</p>
            </div>
            <span className="text-sm font-medium text-orange-900">$400 / $500</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard; 