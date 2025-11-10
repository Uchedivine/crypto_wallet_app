// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/coin_provider.dart';
import '../models/coin_model.dart';
import 'coin_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Fetch coins when app starts
    Future.microtask(
      () => context.read<CoinProvider>().fetchCoins()
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.wallet, color: Color(0xFFBF00FF), size: 28),
            SizedBox(width: 10),
            Text('Crypto Wallet'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFFBF00FF)),
            onPressed: () {
              context.read<CoinProvider>().refreshCoins();
            },
          ),
        ],
      ),
      body: Consumer<CoinProvider>(
        builder: (context, provider, child) {
          //  LOADING STATE 
          if (provider.isLoading && !provider.hasData) {
            return _buildLoadingState();
          }

          //  ERROR STATE 
          if (provider.hasError && !provider.hasData) {
            return _buildErrorState(provider);
          }

          //  EMPTY STATE 
          if (!provider.hasData) {
            return _buildEmptyState();
          }

          //  SUCCESS STATE (SHOW COINS) 
          return RefreshIndicator(
            onRefresh: () => provider.refreshCoins(),
            color: Color(0xFFBF00FF),
            backgroundColor: Color(0xFF1A1A1A),
            child: Column(
              children: [
                // Search Bar
                _buildSearchBar(provider),
                
                // Market Overview (optional stats)
                _buildMarketOverview(provider),
                
                // Coins List
                Expanded(
                  child: provider.filteredCoins.isEmpty
                      ? _buildNoResultsState()
                      : _buildCoinsList(provider.filteredCoins),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //  SEARCH BAR 
  Widget _buildSearchBar(CoinProvider provider) {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search coins...',
          hintStyle: TextStyle(color: Colors.white38),
          prefixIcon: Icon(Icons.search, color: Color(0xFFBF00FF)),
          suffixIcon: provider.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white38),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF2A2A2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFBF00FF), width: 2),
          ),
        ),
        onChanged: (value) {
          provider.updateSearchQuery(value);
        },
      ),
    );
  }

  //  MARKET OVERVIEW 
  Widget _buildMarketOverview(CoinProvider provider) {
    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFBF00FF), Color(0xFF8000CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Coins', provider.coins.length.toString()),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem('Gainers', provider.topGainers.length.toString()),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem('Losers', provider.topLosers.length.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  //  COINS LIST 
  Widget _buildCoinsList(List<Coin> coins) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: coins.length,
      itemBuilder: (context, index) {
        return _buildCoinCard(coins[index]);
      },
    );
  }

  //  COIN CARD 
  Widget _buildCoinCard(Coin coin) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final bool isPriceUp = coin.isPriceUp;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoinDetailScreen(coin: coin),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Coin Logo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    coin.symbol.toUpperCase(),
                    style: TextStyle(
                      color: Color(0xFFBF00FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              
              // Coin Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      coin.symbol.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Price Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${formatter.format(coin.currentPrice)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPriceUp 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPriceUp ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isPriceUp ? Colors.green : Colors.red,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${coin.priceChangePercentage24h.abs().toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isPriceUp ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  LOADING STATE 
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFBF00FF),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Loading coins...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  //  ERROR STATE 
  Widget _buildErrorState(CoinProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Color(0xFFBF00FF),
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => provider.retry(),
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFBF00FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  EMPTY STATE 
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            color: Colors.white24,
            size: 80,
          ),
          SizedBox(height: 20),
          Text(
            'No coins available',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  //  NO SEARCH RESULTS 
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            color: Colors.white24,
            size: 80,
          ),
          SizedBox(height: 20),
          Text(
            'No coins found',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            'Try a different search term',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}