import 'dart:math';

class GenerateUniqueRandomId {

  String generate()  {
    final Random random = Random();
    int randomValue = (100000 + random.nextInt(900000));
    return randomValue.toString();
  }
}