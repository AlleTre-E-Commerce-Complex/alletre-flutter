class Category {
  final int id;
  final String nameEn;
  final String nameAr;
  final bool hasUsageCondition;
  final String sellerDepositFixedAmount;
  final String bidderDepositFixedAmount;
  final String? bannerLink;
  final String? sliderLink;
  final bool status;
  int auctionsCount;
  int listingCount;

  Category(
      {required this.id, required this.nameEn, required this.nameAr, required this.hasUsageCondition, required this.sellerDepositFixedAmount, required this.bidderDepositFixedAmount, this.bannerLink, this.sliderLink, required this.status, required this.auctionsCount, required this.listingCount});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      hasUsageCondition: json['hasUsageCondition'] as bool,
      sellerDepositFixedAmount: json['sellerDepositFixedAmount'] as String,
      bidderDepositFixedAmount: json['bidderDepositFixedAmount'] as String,
      bannerLink: json['bannerLink'] as String?,
      sliderLink: json['sliderLink'] as String?,
      status: json['status'] as bool,
      auctionsCount: 0,
      listingCount: 0,
    );
  }
}
