class CategoryData {
  // Category name to ID mapping
  static const Map<String, int> categoryIds = {
    "Electronic Devices": 1,
    "Jewellers": 2,
    "Properties": 3,
    "Cars": 4,
    "Furniture": 5,
    "Antiques": 6,
  };

  // Subcategory name to ID mapping for each category
  static const Map<String, Map<String, int>> subCategoryIds = {
    "Electronic Devices": {
      "Home Appliances": 1,
      "Computers & tablets": 2,
      "Cameras & photos": 3,
      "TVs & Audios": 4,
      "Smart Phones": 5,
      "Accessories": 6,
    },
    "Jewellers": {
      "Gold": 1,
      "Diamond": 2,
      "Silver": 3,
    },
    "Properties": {
      "House": 1,
      "Townhouse": 2,
      "Unit": 3,
      "Villa": 4,
      "Land": 5,
      "Office": 6,
    },
    "Furniture": {
      "Table and chairs": 1,
      "Cupboards and Beds": 2,
      "Others": 3,
    },
    "Antiques": {
      "Paintings": 1,
      "Currency": 2,
    },
  };

  static const List<String> categories = [
    "Jewellers",
    "Properties",
    "Cars",
    "Electronic Devices",
    "Furniture",
    "Antiques"
  ];

  static const Map<String, List<String>> subCategories = {
    "Jewellers": ["Gold", "Diamond", "Silver"],
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
