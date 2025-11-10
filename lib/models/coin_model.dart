

class Coin {
  final String id;                    // Unique identifier (e.g., "bitcoin")
  final String symbol;                // Short code (e.g., "btc")
  final String name;                  // Full name (e.g., "Bitcoin")
  final String image;                 // Logo URL
  final double currentPrice;          // Current price in USD
  final double priceChange24h;        // Price change in last 24h (dollars)
  final double priceChangePercentage24h; // Price change in last 24h (percentage)
  final double marketCap;             // Total market value
  final int marketCapRank;            // Ranking by market cap
  final double totalVolume;           // Trading volume in 24h
  final double? high24h;              // Highest price in 24h (nullable)
  final double? low24h;               // Lowest price in 24h (nullable)

  Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    this.high24h,
    this.low24h,
  });

  // Factory constructor to create a Coin from JSON
  // This is called when we receive data from the API
  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      priceChange24h: (json['price_change_24h'] ?? 0).toDouble(),
      priceChangePercentage24h: (json['price_change_percentage_24h'] ?? 0).toDouble(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      marketCapRank: json['market_cap_rank'] ?? 0,
      totalVolume: (json['total_volume'] ?? 0).toDouble(),
      high24h: json['high_24h']?.toDouble(),
      low24h: json['low_24h']?.toDouble(),
    );
  }

  // Convert Coin object back to JSON (useful for caching or debugging)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'current_price': currentPrice,
      'price_change_24h': priceChange24h,
      'price_change_percentage_24h': priceChangePercentage24h,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'total_volume': totalVolume,
      'high_24h': high24h,
      'low_24h': low24h,
    };
  }

  // Helper method to check if price went up or down
  bool get isPriceUp => priceChangePercentage24h > 0;

  // Helper method to get formatted price change color
  // This will be useful for UI (green for up, red for down)
  String get priceChangeColor => isPriceUp ? 'green' : 'red';
}