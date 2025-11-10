// lib/providers/coin_provider.dart

import 'package:flutter/foundation.dart';
import '../models/coin_model.dart';
import '../models/chart_data_model.dart';
import '../services/api_service.dart';

// ChangeNotifier allows this class to notify listeners when data changes
class CoinProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ========== STATE VARIABLES ==========
  
  // List of all coins
  List<Coin> _coins = [];
  
  // Current state of the app
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Search functionality
  String _searchQuery = '';
  
  // Connection status
  bool _isConnected = true;

  // Cache for market charts to avoid rate limiting
  Map<String, MarketChart> _chartCache = {};

  // ========== GETTERS (Read-only access to private variables) ==========
  
  List<Coin> get coins => _coins;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isConnected => _isConnected;
  
  // Get filtered coins based on search query
  List<Coin> get filteredCoins {
    if (_searchQuery.isEmpty) {
      return _coins;
    }
    return _coins.where((coin) {
      return coin.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             coin.symbol.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // ========== METHODS ==========

  // 1️⃣ Fetch coins from API
  Future<void> fetchCoins() async {
    // Set loading state
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners(); // Tell all screens to update

    try {
      // Check internet connection first
      _isConnected = await _apiService.checkConnection();
      
      if (!_isConnected) {
        throw Exception('No internet connection');
      }

      // Fetch coins from API
      _coins = await _apiService.fetchCoins();
      
      // Success! Update state
      _isLoading = false;
      _hasError = false;
      notifyListeners();
      
    } catch (e) {
      // Error occurred
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isConnected = false;
      notifyListeners();
      
      // Log error for debugging
      debugPrint('Error fetching coins: $e');
    }
  }

  // 2️⃣ Fetch coin details
  Future<Map<String, dynamic>?> fetchCoinDetails(String coinId) async {
    try {
      return await _apiService.fetchCoinDetails(coinId);
    } catch (e) {
      debugPrint('Error fetching coin details: $e');
      return null;
    }
  }

  // 3️⃣ Fetch market chart data
  Future<MarketChart?> fetchMarketChart(String coinId, {int days = 7}) async {
    try {
      return await _apiService.fetchMarketChart(coinId, days: days);
    } catch (e) {
      debugPrint('Error fetching market chart: $e');
      return null;
    }
  }

  // 4️⃣ Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); // Update UI with filtered results
  }

  // 5️⃣ Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // 6️⃣ Retry fetching coins (useful for error screens)
  Future<void> retry() async {
    await fetchCoins();
  }

  // 7️⃣ Refresh coins (pull-to-refresh)
  Future<void> refreshCoins() async {
    await fetchCoins();
  }

  // 8️⃣ Get a specific coin by ID
  Coin? getCoinById(String coinId) {
    try {
      return _coins.firstWhere((coin) => coin.id == coinId);
    } catch (e) {
      return null;
    }
  }

  // 9️⃣ Check if provider has data
  bool get hasData => _coins.isNotEmpty;

  // 🔟 Get top gainers (coins with highest price increase)
  List<Coin> get topGainers {
    List<Coin> gainers = _coins.where((coin) => coin.isPriceUp).toList();
    gainers.sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
    return gainers.take(5).toList(); // Top 5
  }

  // 1️⃣1️⃣ Get top losers (coins with highest price decrease)
  List<Coin> get topLosers {
    List<Coin> losers = _coins.where((coin) => !coin.isPriceUp).toList();
    losers.sort((a, b) => a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
    return losers.take(5).toList(); // Top 5
  }
}