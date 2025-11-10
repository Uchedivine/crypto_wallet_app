// lib/models/chart_data_model.dart

class ChartData {
  final DateTime date;      // When the price was recorded
  final double price;       // Price at that time

  ChartData({
    required this.date,
    required this.price,
  });

  // Factory constructor to create ChartData from API response
  // API returns data as [timestamp, price]
  factory ChartData.fromJson(List<dynamic> json) {
    return ChartData(
      date: DateTime.fromMillisecondsSinceEpoch(json[0]),
      price: (json[1] ?? 0).toDouble(),
    );
  }
}

// Model for the complete market chart response
class MarketChart {
  final List<ChartData> prices;      // List of price points over time

  MarketChart({
    required this.prices,
  });

  // Factory constructor to create MarketChart from JSON
  factory MarketChart.fromJson(Map<String, dynamic> json) {
    try {
      List<dynamic> pricesJson = json['prices'] ?? [];
      
      print('Parsing ${pricesJson.length} price points');
      
      List<ChartData> pricesList = pricesJson
          .map((pricePoint) {
            try {
              return ChartData.fromJson(pricePoint);
            } catch (e) {
              print('Error parsing price point: $e');
              return null;
            }
          })
          .where((element) => element != null)
          .cast<ChartData>()
          .toList();

      print('Successfully parsed ${pricesList.length} price points');
      return MarketChart(prices: pricesList);
    } catch (e) {
      print('Error in MarketChart.fromJson: $e');
      return MarketChart(prices: []);
    }
  }

  // Helper method to get the highest price in the dataset
  double get maxPrice {
    if (prices.isEmpty) return 0;
    return prices.map((e) => e.price).reduce((a, b) => a > b ? a : b);
  }

  // Helper method to get the lowest price in the dataset
  double get minPrice {
    if (prices.isEmpty) return 0;
    return prices.map((e) => e.price).reduce((a, b) => a < b ? a : b);
  }

  // Calculate price change percentage between first and last price
  double get priceChangePercentage {
    if (prices.isEmpty || prices.length < 2) return 0;
    double firstPrice = prices.first.price;
    double lastPrice = prices.last.price;
    return ((lastPrice - firstPrice) / firstPrice) * 100;
  }
}