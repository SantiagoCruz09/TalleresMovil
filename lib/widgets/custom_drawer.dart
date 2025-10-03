import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            accountName: const Text('Santiago A. Santacruz'),
            accountEmail: const Text('santiago.santacruz01@uceva.edu.co'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage('https://avatars.githubusercontent.com/u/162523782?s=400&u=bc844ab8c77d203fe645b1f523721e90170b18af&v=4'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.autorenew),
            title: const Text('Ciclo Vida'),
            onTap: () {
              Navigator.pop(context);
              context.go('/ciclo');
            },
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Paso Parámetros'),
            onTap: () {
              Navigator.pop(context);
              context.go('/parametros');
            },
          ),
          const Divider(),
          // Nuevos botones solicitados
          ListTile(
            leading: const Icon(Icons.hourglass_bottom),
            title: const Text('Future'),
            onTap: () {
              Navigator.pop(context);
              context.go('/future');
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Async'),
            onTap: () {
              Navigator.pop(context);
              context.go('/async');
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Timer'),
            onTap: () {
              Navigator.pop(context);
              context.go('/timer');
            },
          ),
          ListTile(
            leading: const Icon(Icons.memory),
            title: const Text('Isolate'),
            onTap: () {
              Navigator.pop(context);
              context.go('/isolate');
            },
          ),
        ],
      ),
    );
  }
}
