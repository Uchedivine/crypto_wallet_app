// lib/screens/coin_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/coin_model.dart';
import '../models/chart_data_model.dart';
import '../providers/coin_provider.dart';

class CoinDetailScreen extends StatefulWidget {
  final Coin coin;

  const CoinDetailScreen({Key? key, required this.coin}) : super(key: key);

  @override
  _CoinDetailScreenState createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  MarketChart? _marketChart;
  bool _isLoadingChart = true;
  int _selectedDays = 7;
  String? _chartError;

  @override
  void initState() {
    super.initState();
    _loadMarketChart();
  }

  Future<void> _loadMarketChart() async {
    setState(() {
      _isLoadingChart = true;
      _chartError = null;
    });
    
    try {
      final provider = context.read<CoinProvider>();
      final chart = await provider.fetchMarketChart(widget.coin.id, days: _selectedDays);
      
      print('Chart loaded: ${chart?.prices.length ?? 0} data points');
      
      setState(() {
        _marketChart = chart;
        _isLoadingChart = false;
        _chartError = chart == null || chart.prices.isEmpty 
            ? 'Unable to load chart data' 
            : null;
      });
    } catch (e) {
      print('Error loading chart: $e');
      setState(() {
        _marketChart = null;
        _isLoadingChart = false;
        _chartError = 'Rate limit exceeded. Please wait a moment.';
      });
    }
  }

  void _changeDays(int days) {
    if (_isLoadingChart) return; // Prevent clicking while loading
    
    setState(() {
      _selectedDays = days;
    });
    _loadMarketChart();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final compactFormatter = NumberFormat.compact();
    final bool isPriceUp = widget.coin.isPriceUp;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.coin.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFBF00FF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Header
            _buildPriceHeader(formatter, isPriceUp),
            
            // Time Range Selector
            _buildTimeRangeSelector(),
            
            // Price Chart
            _buildChart(),
            
            // Stats Section
            _buildStatsSection(formatter, compactFormatter),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ========== PRICE HEADER ==========
  Widget _buildPriceHeader(NumberFormat formatter, bool isPriceUp) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symbol Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFBF00FF), width: 1),
            ),
            child: Text(
              widget.coin.symbol.toUpperCase(),
              style: TextStyle(
                color: Color(0xFFBF00FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Current Price
          Text(
            '\$${formatter.format(widget.coin.currentPrice)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          
          // Price Change
          Row(
            children: [
              Icon(
                isPriceUp ? Icons.trending_up : Icons.trending_down,
                color: isPriceUp ? Colors.green : Colors.red,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '\$${widget.coin.priceChange24h.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: isPriceUp ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPriceUp 
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isPriceUp ? '+' : ''}${widget.coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPriceUp ? Colors.green : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== TIME RANGE SELECTOR ==========
  Widget _buildTimeRangeSelector() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildTimeButton('24H', 1),
          SizedBox(width: 8),
          _buildTimeButton('7D', 7),
          SizedBox(width: 8),
          _buildTimeButton('30D', 30),
          SizedBox(width: 8),
          _buildTimeButton('1Y', 365),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String label, int days) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeDays(days),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFBF00FF) : Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========== CHART ==========
  Widget _buildChart() {
    return Container(
      height: 300,
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _isLoadingChart
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFBF00FF),
              ),
            )
          : _chartError != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, 
                           color: Color(0xFFBF00FF), 
                           size: 48),
                      SizedBox(height: 12),
                      Text(
                        _chartError!,
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      if (_chartError!.contains('Rate limit'))
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Charts are cached. Try again in a minute.',
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                )
              : _marketChart == null || _marketChart!.prices.isEmpty
                  ? Center(
                      child: Text(
                        'No chart data available',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : _buildLineChart(),
    );
  }

  Widget _buildLineChart() {
    final spots = _marketChart!.prices.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.price);
    }).toList();

    final minPrice = _marketChart!.minPrice;
    final maxPrice = _marketChart!.maxPrice;
    final isPriceUp = _marketChart!.priceChangePercentage >= 0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: spots.length.toDouble() - 1,
        minY: minPrice * 0.995,
        maxY: maxPrice * 1.005,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: isPriceUp ? Colors.green : Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  (isPriceUp ? Colors.green : Colors.red).withOpacity(0.3),
                  (isPriceUp ? Colors.green : Colors.red).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== STATS SECTION ==========
  Widget _buildStatsSection(NumberFormat formatter, NumberFormat compactFormatter) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Stats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          _buildStatCard(
            'Market Cap',
            '\$${compactFormatter.format(widget.coin.marketCap)}',
            Icons.bar_chart,
          ),
          SizedBox(height: 12),
          
          _buildStatCard(
            '24h Volume',
            '\$${compactFormatter.format(widget.coin.totalVolume)}',
            Icons.show_chart,
          ),
          SizedBox(height: 12),
          
          if (widget.coin.high24h != null)
            _buildStatCard(
              '24h High',
              '\$${formatter.format(widget.coin.high24h!)}',
              Icons.arrow_upward,
            ),
          SizedBox(height: 12),
          
          if (widget.coin.low24h != null)
            _buildStatCard(
              '24h Low',
              '\$${formatter.format(widget.coin.low24h!)}',
              Icons.arrow_downward,
            ),
          SizedBox(height: 12),
          
          _buildStatCard(
            'Market Cap Rank',
            '#${widget.coin.marketCapRank}',
            Icons.leaderboard,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFBF00FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Color(0xFFBF00FF),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}