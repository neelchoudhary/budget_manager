class Category {
  int categoryId;
  String categoryPlaidID;
  String group;
  List<String> categories = [];

  Category();

  factory Category.fromJson(json) {
    Category c = Category();
    c.categoryId = json['id'];
    c.categoryPlaidID = json['category_id_plaid'];
    c.group = json['category_group'] as String;
    c.categories.add(json['category1'] as String);
    if (json['category2'] != "") {
      c.categories.add(json['category2'] as String);
    }
    if (json['category3'] != "") {
      c.categories.add(json['category3'] as String);
    }

    return c;
  }

  @override
  String toString() {
    return this.categories[this.categories.length - 1];
  }

  String toStringDebug() {
    return this.categoryId.toString();
  }
}
