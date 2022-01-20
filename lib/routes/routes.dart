import 'package:flutter/material.dart';
import 'package:medirutas/pages/choiceBus.dart';
import 'package:medirutas/pages/loadingPage.dart';


import '../pages/home/MapActivity.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
    'loading': (_) => LoadingPage(),
    'home': (_) => MapActivity(),
    'choice_bus': (_) => ChoiceBus()
  };