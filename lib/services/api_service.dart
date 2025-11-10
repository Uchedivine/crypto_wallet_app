// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coin_model.dart';
import '../models/chart_data_model.dart';

class ApiService {
  // Base URL for CoinGecko API
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  
  // Timeout duration for API calls
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // 1️⃣ Fetch list of coins (top 50 by market cap)
  // This will be used on the home screen
  Future<List<Coin>> fetchCoins() async {
    try {
      final url = Uri.parse(
        '$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false'
      );

      // Make the HTTP GET request with timeout
      final response = await http.get(url).timeout(_timeoutDuration);

      // Check if request was successful (status code 200)
      if (response.statusCode == 200) {
        // Decode JSON response
        List<dynamic> data = json.decode(response.body);
        
        // Convert each JSON object to a Coin object
        List<Coin> coins = data.map((json) => Coin.fromJson(json)).toList();
        
        return coins;
      } else {
        // API returned an error
        throw Exception('Failed to load coins: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors (network issues, timeout, parsing errors)
      throw Exception('Error fetching coins: $e');
    }
  }

  // 2️⃣ Fetch detailed information for a specific coin
  // This will be used on the coin detail screen
  Future<Map<String, dynamic>> fetchCoinDetails(String coinId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/coins/$coinId?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false'
      );

      final response = await http.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        // Return the full JSON response
        // We'll extract what we need in the UI
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load coin details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching coin details: $e');
    }
  }

  // 3️⃣ Fetch market chart data (price history)
  // This will be used to draw the price chart
  Future<MarketChart> fetchMarketChart(String coinId, {int days = 7}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/coins/$coinId/market_chart?vs_currency=usd&days=$days'
      );

      print('Fetching market chart from: $url');
      
      final response = await http.get(url).timeout(_timeoutDuration);

      print('Market chart response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        
        print('Market chart data keys: ${data.keys}');
        print('Prices count: ${data['prices']?.length ?? 0}');
        
        // Convert JSON to MarketChart object
        MarketChart marketChart = MarketChart.fromJson(data);
        
        print('MarketChart created with ${marketChart.prices.length} prices');
        
        return marketChart;
      } else {
        print('Market chart error response: ${response.body}');
        throw Exception('Failed to load market chart: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchMarketChart: $e');
      throw Exception('Error fetching market chart: $e');
    }
  }

  // 4️⃣ Search for coins by name or symbol
  // Bonus feature: useful for implementing a search functionality later
  Future<List<Coin>> searchCoins(String query) async {
    try {
      // First, get all coins
      List<Coin> allCoins = await fetchCoins();
      
      // Filter coins based on search query
      List<Coin> filteredCoins = allCoins.where((coin) {
        return coin.name.toLowerCase().contains(query.toLowerCase()) ||
               coin.symbol.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      return filteredCoins;
    } catch (e) {
      throw Exception('Error searching coins: $e');
    }
  }

  // 5️⃣ Helper method to check if API is reachable
  // Useful for checking internet connectivity
  Future<bool> checkConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/ping');
      final response = await http.get(url).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}