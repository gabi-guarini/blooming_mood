class PlantResult {
  String name;
  String color;
  String imagePath;
  String message;

  PlantResult(
    this.name,
    this.color,
    this.imagePath,
    this.message,
  );

  String findColor() {
    return "#E50B66";
  }

  String makeImagePath() {
    return "src/images/$name.png";
  }
}
