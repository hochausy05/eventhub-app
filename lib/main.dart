import 'package:eventhub_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const ProviderScope(child: EventHubApp()));
}
