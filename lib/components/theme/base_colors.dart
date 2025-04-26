import 'dart:ui';

abstract class BaseColors {
  const BaseColors();

  Color get primary => const Color.fromRGBO(0, 111, 229, 1);

  Color get primary30 => const Color.fromRGBO(81, 166, 255, 1);

  Color get white => const Color.fromRGBO(255, 255, 255, 1);

  Color get black => const Color.fromRGBO(0, 0, 0, 1);

  Color get green => const Color.fromRGBO(0, 216, 86, 1);

  Color get lightGreen => const Color.fromRGBO(91, 255, 81, 1.0);

  Color get red => const Color.fromRGBO(235, 87, 87, 1);

  Color get redLight => const Color.fromRGBO(255, 0, 0, 0.4);

  Color get orange => const Color.fromRGBO(255, 165, 0, 1);

  Color get yellow => const Color.fromRGBO(255, 255, 131, 1);

  Color get dark => const Color.fromRGBO(36, 36, 36, 1);

  Color get darkText => const Color.fromRGBO(87, 87, 87, 1);

  Color get darkBlue => const Color.fromRGBO(129, 146, 165, 1);

  Color get blueGray => const Color.fromRGBO(177, 184, 200, 1);

  Color get blueGray50 => const Color.fromRGBO(220, 225, 235, 1);

  Color get background => const Color.fromRGBO(241, 243, 247, 1);

  Color get background50 => const Color.fromRGBO(248, 249, 251, 1);

  Color get iconColor => const Color.fromRGBO(231, 243, 255, 1);
}
