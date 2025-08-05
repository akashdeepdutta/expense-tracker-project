import React, { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { Camera, Upload, FileText, CheckCircle, AlertCircle } from 'lucide-react';
import { scanReceipt, createExpense } from '../services/api';
import toast from 'react-hot-toast';

const ReceiptScanner: React.FC = () => {
  const [isProcessing, setIsProcessing] = useState(false);
  const [receiptData, setReceiptData] = useState<any>(null);
  const [previewImage, setPreviewImage] = useState<string | null>(null);

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    const file = acceptedFiles[0];
    if (!file) return;

    // Create preview
    const reader = new FileReader();
    reader.onload = (e) => {
      setPreviewImage(e.target?.result as string);
    };
    reader.readAsDataURL(file);

    // Process receipt
    setIsProcessing(true);
    try {
      // Convert to base64
      const base64 = await fileToBase64(file);
      const imageFormat = file.name.split('.').pop() || 'jpeg';

      // Scan receipt
      const data = await scanReceipt(base64, imageFormat);
      setReceiptData(data);
      toast.success('Receipt scanned successfully!');
    } catch (error) {
      console.error('Error scanning receipt:', error);
      toast.error('Failed to scan receipt. Please try again.');
    } finally {
      setIsProcessing(false);
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.gif', '.bmp']
    },
    multiple: false
  });

  const fileToBase64 = (file: File): Promise<string> => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => {
        const result = reader.result as string;
        // Remove data URL prefix
        const base64 = result.split(',')[1];
        resolve(base64);
      };
      reader.onerror = error => reject(error);
    });
  };

  const handleCreateExpense = async () => {
    if (!receiptData) return;

    try {
      const expense = {
        title: receiptData.merchantName || 'Receipt Expense',
        amount: receiptData.totalAmount,
        currencyCode: 'USD', // Default currency
        date: receiptData.date,
        description: `Scanned receipt from ${receiptData.merchantName}`,
        isReimbursable: false
      };

      await createExpense(expense);
      toast.success('Expense created successfully!');
      
      // Reset form
      setReceiptData(null);
      setPreviewImage(null);
    } catch (error) {
      console.error('Error creating expense:', error);
      toast.error('Failed to create expense. Please try again.');
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Receipt Scanner</h1>
        <p className="text-gray-600">Upload a receipt image to automatically extract expense data</p>
      </div>

      {/* Upload Area */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
        <div
          {...getRootProps()}
          className={`border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors ${
            isDragActive
              ? 'border-blue-400 bg-blue-50'
              : 'border-gray-300 hover:border-gray-400'
          }`}
        >
          <input {...getInputProps()} />
          
          {isProcessing ? (
            <div className="space-y-4">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
              <p className="text-gray-600">Processing receipt...</p>
            </div>
          ) : previewImage ? (
            <div className="space-y-4">
              <img 
                src={previewImage} 
                alt="Receipt preview" 
                className="max-w-md mx-auto rounded-lg shadow-sm"
              />
              <p className="text-sm text-gray-500">Click or drag to replace image</p>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="mx-auto w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center">
                <Camera className="w-8 h-8 text-gray-400" />
              </div>
              <div>
                <p className="text-lg font-medium text-gray-900">
                  {isDragActive ? 'Drop the receipt here' : 'Upload receipt image'}
                </p>
                <p className="text-sm text-gray-500 mt-1">
                  Drag and drop an image, or click to select
                </p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Extracted Data */}
      {receiptData && (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center space-x-2 mb-4">
            <CheckCircle className="w-5 h-5 text-green-500" />
            <h3 className="text-lg font-semibold text-gray-900">Extracted Data</h3>
            <span className="text-sm text-gray-500">
              Confidence: {receiptData.confidence?.toFixed(1)}%
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Merchant</label>
                <p className="mt-1 text-sm text-gray-900">{receiptData.merchantName}</p>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Total Amount</label>
                <p className="mt-1 text-sm text-gray-900">${receiptData.totalAmount?.toFixed(2)}</p>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Tax Amount</label>
                <p className="mt-1 text-sm text-gray-900">${receiptData.taxAmount?.toFixed(2)}</p>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Date</label>
                <p className="mt-1 text-sm text-gray-900">{receiptData.date}</p>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Items</label>
              <div className="space-y-2 max-h-40 overflow-y-auto">
                {receiptData.items?.map((item: any, index: number) => (
                  <div key={index} className="flex justify-between text-sm">
                    <span className="text-gray-900">{item.name}</span>
                    <span className="text-gray-600">${item.price?.toFixed(2)}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="mt-6 flex space-x-3">
            <button
              onClick={handleCreateExpense}
              className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors"
            >
              Create Expense
            </button>
            <button
              onClick={() => {
                setReceiptData(null);
                setPreviewImage(null);
              }}
              className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition-colors"
            >
              Scan Another
            </button>
          </div>
        </div>
      )}

      {/* OCR Text */}
      {receiptData?.ocrText && (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center space-x-2 mb-4">
            <FileText className="w-5 h-5 text-gray-500" />
            <h3 className="text-lg font-semibold text-gray-900">OCR Text</h3>
          </div>
          <pre className="text-sm text-gray-700 bg-gray-50 p-4 rounded-md overflow-x-auto">
            {receiptData.ocrText}
          </pre>
        </div>
      )}

      {/* Tips */}
      <div className="bg-blue-50 rounded-lg p-6">
        <div className="flex items-start space-x-3">
          <AlertCircle className="w-5 h-5 text-blue-500 mt-0.5" />
          <div>
            <h3 className="text-sm font-medium text-blue-900">Tips for better scanning</h3>
            <ul className="mt-2 text-sm text-blue-700 space-y-1">
              <li>• Ensure good lighting and clear image quality</li>
              <li>• Position the receipt flat and avoid shadows</li>
              <li>• Make sure all text is clearly visible</li>
              <li>• Supported formats: JPEG, PNG, GIF, BMP</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ReceiptScanner; 