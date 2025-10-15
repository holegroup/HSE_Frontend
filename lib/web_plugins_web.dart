// Web-specific implementation
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void initializeWebPlugins() {
  // Initialize web-specific features
  setUrlStrategy(PathUrlStrategy());
}
