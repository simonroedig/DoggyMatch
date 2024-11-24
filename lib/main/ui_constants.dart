class UIConstants {
  static const double clipping = 3;
  static const radiusDif1 = 8;
  static const radiusDif2 = 6;
  static const double outerRadius = 18;
  static const double outerRadiusClipped = outerRadius - clipping;
  static const double innerRadius = outerRadius - radiusDif1;
  static const double innerRadiusClipped = outerRadius - radiusDif1 - clipping;
  static const double innerInnerRadius = innerRadius - radiusDif2;
  static const double innerInnerRadiusClipped =
      innerRadius - radiusDif2 - clipping;
  static const double popUpRadius = innerRadius;
  static const double padding = 10;
}
