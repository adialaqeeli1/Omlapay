import '../models/transaction_model/transaction_model.dart';
import '../models/coin_model/coin_model.dart';
import '../models/contact_model/contact_model.dart';
import '../models/user_model/user_model.dart';
import '../models/wallet_model/wallet_model.dart';

class MockData {
  /// Mock overrides for passcode reset. Key: countryCode + phoneNumber.
  static final Map<String, String> passcodeOverrides = {};

  static const List<UserModel> dummyUsers = [
    UserModel(
      mobileNumber: '123456789',
      countryCode: '+966',
      password: '123456',
      firstName: 'Ahmed',
      lastName: 'Al-Saud',
    ),
    UserModel(
      mobileNumber: '502345678',
      countryCode: '+966',
      password: '234567',
      firstName: 'Fatima',
      lastName: 'Al-Rashid',
    ),
    UserModel(
      mobileNumber: '503456789',
      countryCode: '+966',
      password: '345678',
      firstName: 'Mohammed',
      lastName: 'Al-Otaibi',
    ),
    UserModel(
      mobileNumber: '504567890',
      countryCode: '+966',
      password: '456789',
      firstName: 'Sara',
      lastName: 'Al-Mutairi',
    ),
    UserModel(
      mobileNumber: '505678901',
      countryCode: '+966',
      password: '567890',
      firstName: 'Khalid',
      lastName: 'Al-Ghamdi',
    ),
  ];

  static final List<CoinModel> coins = [
    CoinModel(
      name: 'Tether USDT',
      symbol: 'USDT',
      amount: '200,023.20',
      valueInUsd: '≈200,023.20',
    ),
    CoinModel(
      name: 'Ethereum',
      symbol: 'ETH',
      amount: '1.45',
      valueInUsd: '≈3,500.00',
    ),
    CoinModel(
      name: 'Bitcoin',
      symbol: 'BTC',
      amount: '0.05',
      valueInUsd: '≈3,200.00',
    ),
  ];

  static final List<WalletCoinModel> wallets = [
    WalletCoinModel(
      name: 'Tron',
      symbol: 'TRX',
      address: 'TG7gaA4MeqeAsWjdaMe5ubh3SadfjqMsDbc',
      network: 'TRC20',
      networkDisplayName: 'Tron (TRC20)',
    ),
    WalletCoinModel(
      name: 'Bitcoin',
      symbol: 'BTC',
      address: '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
      network: 'Bitcoin',
      networkDisplayName: 'Bitcoin',
    ),
    WalletCoinModel(
      name: 'EVM',
      symbol: 'ETH',
      address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEba',
      network: 'ERC20',
      networkDisplayName: 'Ethereum (ERC20)',
    ),
    WalletCoinModel(
      name: 'Solana',
      symbol: 'SOL',
      address: 'DxLHgh7N76vSaSddAY7qPb2dgx8b45hBQ8fYzz7YdQba',
      network: 'Solana',
      networkDisplayName: 'Solana',
    ),
  ];

  static List<TransactionModel> getTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: '1',
        assetSymbol: 'USDT',
        assetName: 'Tether USDT',
        amount: '+100.50000000',
        network: 'TRC20',
        status: 'COMPLETED',
        createdAt: now.subtract(const Duration(hours: 2)),
        txHash: '0x9876543210abcdef',
      ),
      TransactionModel(
        id: '2',
        assetSymbol: 'BTC',
        assetName: 'Bitcoin',
        amount: '-0.00500000',
        network: 'BTC',
        status: 'COMPLETED',
        createdAt: now.subtract(const Duration(days: 1)),
        txHash:
            'a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d',
      ),
      TransactionModel(
        id: '3',
        assetSymbol: 'ETH',
        assetName: 'Ethereum',
        amount: '+0.50000000',
        network: 'ETH',
        status: 'PENDING',
        createdAt: now.subtract(const Duration(hours: 5)),
        txHash: null,
      ),
      TransactionModel(
        id: '4',
        assetSymbol: 'USDT',
        assetName: 'Tether USDT',
        amount: '+50.00000000',
        network: 'TRC20',
        status: 'COMPLETED',
        createdAt: now.subtract(const Duration(days: 2)),
        txHash: '0xabcdef1234567890',
      ),
      TransactionModel(
        id: '5',
        assetSymbol: 'BTC',
        assetName: 'Bitcoin',
        amount: '-0.00100000',
        network: 'BTC',
        status: 'FAILED',
        createdAt: now.subtract(const Duration(days: 3)),
        txHash: null,
      ),
      TransactionModel(
        id: '6',
        assetSymbol: 'ETH',
        assetName: 'Ethereum',
        amount: '+1.00000000',
        network: 'ETH',
        status: 'COMPLETED',
        createdAt: now.subtract(const Duration(days: 5)),
        txHash: '0x1234567890abcdef',
      ),
      TransactionModel(
        id: '7',
        assetSymbol: 'USDT',
        assetName: 'Tether USDT',
        amount: '-170.00000000',
        network: 'TRC20',
        status: 'FAILED',
        createdAt: DateTime(2024, 7, 10, 12, 6, 20),
        txHash: null,
      ),
      TransactionModel(
        id: '8',
        assetSymbol: 'BTC',
        assetName: 'Bitcoin',
        amount: '+170.00000000',
        network: 'BTC',
        status: 'COMPLETED',
        createdAt: DateTime(2024, 7, 10, 12, 6, 20),
        txHash:
            'a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d',
      ),
      TransactionModel(
        id: '9',
        assetSymbol: 'USDT',
        assetName: 'Tether USDT',
        amount: '+50.00000000',
        network: 'TRC20',
        status: 'PENDING',
        createdAt: DateTime(2024, 7, 15, 10, 30, 0),
        txHash: null,
      ),
      TransactionModel(
        id: '10',
        assetSymbol: 'SOL',
        assetName: 'Solana',
        amount: '+100.00000000',
        network: 'SOL',
        status: 'COMPLETED',
        createdAt: DateTime(2024, 7, 20, 8, 15, 0),
        txHash:
            '5VERv8NMvzbJMEkV8xnrLkEaWRtSz9CosKDYjCJjBRnbJLgp8uirBgmQpjKhoR4tjF3ZpBzrW2mrV4xY4EPr8i8pm',
      ),
    ];
  }

  static final List<ContactModel> contacts = [
    ContactModel(
      id: 'c1',
      name: 'Abdullah Ali',
      phoneNumber: '+966 50 123 4567',
      isVerified: false,
    ),
    ContactModel(
      id: 'c2',
      name: 'Sarah Ahmed',
      phoneNumber: '+966 55 987 6543',
      isVerified: true,
    ),
    ContactModel(
      id: 'c3',
      name: 'Mohammed Al-Saud',
      phoneNumber: '+966 54 321 0987',
      isVerified: false,
    ),
    ContactModel(
      id: 'c4',
      name: 'Fatima Al-Rashid',
      phoneNumber: '+966 56 789 0123',
      isVerified: true,
    ),
    ContactModel(
      id: 'c5',
      name: 'Khalid Al-Ghamdi',
      phoneNumber: '+966 59 456 1230',
      isVerified: false,
    ),
  ];
}
