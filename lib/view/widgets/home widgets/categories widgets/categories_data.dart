class CategoryData {
  static const List<String> categories = [
    "Jewellery",
    "Properties",
    "Cars",
    "Electronic Devices",
  ];

  static const Map<String, List<String>> subCategories = {
    "Jewellery": ["Gold", "Diamond", "Silver"],
    "Properties": ["House", "Townhouse", "Unit", "Villa", "Land", "Office"],
    "Cars": ["SUVs", "Sedans", "Electric"],
    "Electronic Devices": [
      "Computers & tablets",
      "Cameras & photos",
      "TVs & Audios",
      "Smart Phones",
      "Accessories",
      "Home Appliances"
    ],
  };
}
