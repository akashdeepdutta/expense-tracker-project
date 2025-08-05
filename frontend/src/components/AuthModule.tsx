import React, { useState } from 'react';
import { User, LogIn, UserPlus, LogOut } from 'lucide-react';

interface AuthModuleProps {
  isAuthenticated?: boolean;
  username?: string;
}

const AuthModule: React.FC<AuthModuleProps> = ({ 
  isAuthenticated = false, 
  username = 'User' 
}) => {
  const [showDropdown, setShowDropdown] = useState(false);

  const handleLogin = () => {
    // TODO: Implement login functionality
    console.log('Login clicked');
  };

  const handleRegister = () => {
    // TODO: Implement register functionality
    console.log('Register clicked');
  };

  const handleLogout = () => {
    // TODO: Implement logout functionality
    console.log('Logout clicked');
  };

  if (isAuthenticated) {
    return (
      <div className="relative">
        <button
          onClick={() => setShowDropdown(!showDropdown)}
          className="flex items-center space-x-2 p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-50 transition-colors"
        >
          <User className="w-5 h-5" />
          <span className="text-sm font-medium">{username}</span>
        </button>
        
        {showDropdown && (
          <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50 border border-gray-200">
            <button
              onClick={handleLogout}
              className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
            >
              <LogOut className="w-4 h-4 mr-2" />
              Logout
            </button>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="flex items-center space-x-2">
      <button
        onClick={handleLogin}
        className="flex items-center space-x-1 px-3 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors"
      >
        <LogIn className="w-4 h-4" />
        <span>Login</span>
      </button>
      <button
        onClick={handleRegister}
        className="flex items-center space-x-1 px-3 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md transition-colors"
      >
        <UserPlus className="w-4 h-4" />
        <span>Register</span>
      </button>
    </div>
  );
};

export default AuthModule; 