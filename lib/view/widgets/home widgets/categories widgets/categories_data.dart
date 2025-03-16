class CategoryData {
  static const List<String> categories = [
    "Jewellery",
    "Properties",
    "Cars",
    "Electronic Devices",
    "Furniture",
    "Antiques"
  ];

  static const Map<String, List<String>> subCategories = {
    "Jewellery": ["Gold", "Diamond", "Silver"],
    "Properties": ["House", "Townhouse", "Unit", "Villa", "Land", "Office"],
    "Electronic Devices": [
      "Computers & tablets",
      "Cameras & photos",
      "TVs & Audios",
      "Smart Phones",
      "Accessories",
      "Home Appliances"
    ],
    "Furniture": ["Table and chairs", "Cupboards and Beds", "Others"],
    "Antiques": ["Paintings", "Currency"]
  };
}
