import 'package:flutter/material.dart';
import 'package:medirutas/pages/choice_bus.dart';
import 'package:medirutas/pages/loading_page.dart';

import '../pages/home/map_activity.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'loading': (_) => const LoadingPage(),
  'home': (_) => const MapActivity(),
  'choice_bus': (_) => const ChoiceBus()
};
