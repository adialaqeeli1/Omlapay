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

  static final List<WalletModel> wallets = [
    WalletModel(
      id: 'w1',
      name: 'Tron',
      symbol: 'TRX',
      address: 'TG7gaA4MeqeAsWjdaMe5ubh3SadfjqMsDbc',
      network: 'TRC20',
    ),
    WalletModel(
      id: 'w2',
      name: 'Bitcoin',
      symbol: 'BTC',
      address: '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
      network: 'Bitcoin',
    ),
    WalletModel(
      id: 'w3',
      name: 'EVM',
      symbol: 'ETH',
      address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEba',
      network: 'ERC20',
    ),
    WalletModel(
      id: 'w4',
      name: 'Solana',
      symbol: 'SOL',
      address: 'DxLHgh7N76vSaSddAY7qPb2dgx8b45hBQ8fYzz7YdQba',
      network: 'Solana',
    ),
  ];

  static List<TransactionModel> getTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: '1',
        coinSymbol: 'USDT',
        coinName: 'Tether USDT',
        amount: '100.50',
        valueInCurrency: '100.50',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(hours: 2)),
        toAddress: '0x1234...5678',
        fromAddress: '0xabcd...efgh',
        transactionHash: '0x9876543210abcdef',
        fee: 0.5,
        note: 'Payment received',
      ),
      TransactionModel(
        id: '2',
        coinSymbol: 'BTC',
        coinName: 'Bitcoin',
        amount: '0.005',
        valueInCurrency: '250.00',
        type: TransactionType.sent,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 1)),
        toAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        fromAddress: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
        transactionHash:
            'a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d',
        fee: 0.0001,
        note: 'Sent to friend',
      ),
      TransactionModel(
        id: '3',
        coinSymbol: 'ETH',
        coinName: 'Ethereum',
        amount: '0.5',
        valueInCurrency: '1250.00',
        type: TransactionType.swap,
        status: TransactionStatus.pending,
        date: now.subtract(const Duration(hours: 5)),
        toAddress: null,
        fromAddress: null,
        transactionHash: null,
        fee: 0.01,
        note: 'Swapped ETH to USDT',
      ),
      TransactionModel(
        id: '4',
        coinSymbol: 'USDT',
        coinName: 'Tether USDT',
        amount: '50.00',
        valueInCurrency: '50.00',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 2)),
        toAddress: '0x1234...5678',
        fromAddress: '0xijkl...mnop',
        transactionHash: '0xabcdef1234567890',
        fee: 0.3,
      ),
      TransactionModel(
        id: '5',
        coinSymbol: 'BTC',
        coinName: 'Bitcoin',
        amount: '0.001',
        valueInCurrency: '50.00',
        type: TransactionType.sent,
        status: TransactionStatus.failed,
        date: now.subtract(const Duration(days: 3)),
        toAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        fromAddress: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
        transactionHash: null,
        fee: 0.00005,
        note: 'Transaction failed',
      ),
      TransactionModel(
        id: '6',
        coinSymbol: 'ETH',
        coinName: 'Ethereum',
        amount: '1.0',
        valueInCurrency: '2500.00',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 5)),
        toAddress: '0x1234...5678',
        fromAddress: '0xqrst...uvwx',
        transactionHash: '0x1234567890abcdef',
        fee: 0.02,
      ),
      TransactionModel(
        id: '7',
        coinSymbol: 'USDT',
        coinName: 'Tether USDT',
        amount: '170.00',
        valueInCurrency: '170.00',
        type: TransactionType.sent,
        status: TransactionStatus.failed,
        date: DateTime(2024, 7, 10, 12, 6, 20),
        toAddress: '0x1234...5678',
        fromAddress: '0xabcd...efgh',
        transactionHash: null,
        fee: 0.5,
      ),
      TransactionModel(
        id: '8',
        coinSymbol: 'BTC',
        coinName: 'Bitcoin',
        amount: '170.00',
        valueInCurrency: '8500000.00',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: DateTime(2024, 7, 10, 12, 6, 20),
        toAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        fromAddress: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
        transactionHash:
            'a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d',
        fee: 0.0001,
      ),
      TransactionModel(
        id: '9',
        coinSymbol: 'USDT',
        coinName: 'Tether USDT',
        amount: '50.00',
        valueInCurrency: '50.00',
        type: TransactionType.received,
        status: TransactionStatus.pending,
        date: DateTime(2024, 7, 15, 10, 30, 0),
        toAddress: '0x1234...5678',
        fromAddress: '0xijkl...mnop',
        transactionHash: null,
        fee: 0.3,
      ),
      TransactionModel(
        id: '10',
        coinSymbol: 'SOL',
        coinName: 'Solana',
        amount: '100.00',
        valueInCurrency: '15000.00',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: DateTime(2024, 7, 20, 8, 15, 0),
        toAddress: '7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU',
        fromAddress: '9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM',
        transactionHash:
            '5VERv8NMvzbJMEkV8xnrLkEaWRtSz9CosKDYjCJjBRnbJLgp8uirBgmQpjKhoR4tjF3ZpBzrW2mrV4xY4EPr8i8pm',
        fee: 0.00025,
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
