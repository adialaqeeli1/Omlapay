import '../models/transaction_model/transaction_model.dart';
import '../models/coin_model/coin_model.dart';
import '../models/contact_model/contact_model.dart';
import '../models/wallet_model/wallet_model.dart';

class MockData {
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
        id: 'tx_1',
        coinSymbol: 'USDT',
        coinName: 'Tether USDT',
        amount: '170.00',
        valueInCurrency: '170.00',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: now,
        toAddress: '0x123...abc',
        fromAddress: null,
        transactionHash: '0x1234567890abcdef',
        fee: 0.5,
        note: 'Payment received',
      ),
      TransactionModel(
        id: 'tx_2',
        coinSymbol: 'BTC',
        coinName: 'Bitcoin',
        amount: '0.5',
        valueInCurrency: '25000.00',
        type: TransactionType.sent,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(hours: 2)),
        toAddress: '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
        fromAddress: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
        transactionHash: 'a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d',
        fee: 0.0001,
        note: 'Sent to friend',
      ),
      TransactionModel(
        id: 'tx_3',
        coinSymbol: 'ETH',
        coinName: 'Ethereum',
        amount: '2.5',
        valueInCurrency: '6250.00',
        type: TransactionType.swap,
        status: TransactionStatus.pending,
        date: now.subtract(const Duration(days: 1)),
        toAddress: null,
        fromAddress: null,
        transactionHash: null,
        fee: 0.01,
        note: 'Swapped ETH to USDT',
      ),
      TransactionModel(
        id: 'tx_4',
        coinSymbol: 'USDT',
        coinName: 'Tether USDT',
        amount: '50.00',
        valueInCurrency: '50.00',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: DateTime(2024, 7, 10, 12, 6, 20),
        toAddress: '0x789...ghi',
        fromAddress: '0x456...def',
        transactionHash: '0x9876543210fedcba',
        fee: 0.3,
        note: null,
      ),
      TransactionModel(
        id: 'tx_5',
        coinSymbol: 'BTC',
        coinName: 'Bitcoin',
        amount: '0.01',
        valueInCurrency: '500.00',
        type: TransactionType.sent,
        status: TransactionStatus.completed,
        date: DateTime(2024, 7, 10, 12, 6, 20),
        toAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        fromAddress: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
        transactionHash: 'b2086ec66e527e4db299g66c7195f3226c0456f27d6dg413gd90e0g6cgc6e59',
        fee: 0.00005,
        note: 'Payment',
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
