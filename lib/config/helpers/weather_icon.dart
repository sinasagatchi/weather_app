import 'package:flutter/material.dart';

IconData weatherIconForCode(String code) {
  final numericCode = int.tryParse(code) ?? 1000;
  if ([1087, 1273, 1276, 1279, 1282].contains(numericCode)) {
    return Icons.thunderstorm_outlined;
  }
  if ([1063, 1150, 1153, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246]
      .contains(numericCode)) {
    return Icons.water_drop_outlined;
  }
  if ([1066, 1069, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258]
      .contains(numericCode)) {
    return Icons.ac_unit;
  }
  if ([1003, 1006, 1009, 1030, 1135, 1147].contains(numericCode)) {
    return Icons.cloud_outlined;
  }
  return Icons.wb_sunny_outlined;
}
