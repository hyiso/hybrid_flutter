import 'package:flutter/material.dart';
import 'package:hybrid_flutter/hybrid_flutter.dart';

Map<String, WidgetBuilder> get pages => {
  '/': (ctx) => Container(),
  '/home': (ctx) => MyPage(),
  '/share': (ctx) => MyPage(),
  '/spawn': (ctx) => MyPage(),
};

class MyPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    print('build ${route?.settings}');
    String title = 'Home';
    if (route?.settings.name == '/share') {
      title = 'ShareEngine: ${(route?.settings.arguments as Map)["index"]}';
    } else if (route?.settings.name == '/spawn') {
      title = 'SpawnEngine: ${(route?.settings.arguments as Map)["index"]}';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                HybridNavigator.pushNamed(context, '/share');
              },
              child: const Text('Share Engine')
            ),
            TextButton(
              onPressed: () {
                HybridNavigator.pushNamed(context, '/spawn', arguments: {
                  'useNewEngine': '1',
                });
              },
              child: const Text('Spawn Engine')
            ),
          ],
        ),
      ),
    );
  }
}