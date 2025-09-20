import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.autorenew),
            title: const Text('Ciclo Vida'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ciclo_vida');
            },
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Paso Parámetros'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/paso_parametros');
            },
          ),
        ],
      ),
    );
  }
}
