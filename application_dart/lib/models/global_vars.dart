
class GlobalVars {
  // Singleton pattern
  static final GlobalVars _instance = GlobalVars._internal();

  // Private constructor to ensure only one instance is created
  factory GlobalVars() => _instance;

  GlobalVars._internal();

  // Global variables
  String? uid = '';

  // You can add more global variables here
}