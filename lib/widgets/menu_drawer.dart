import 'package:consumir_api/screens/admin_screen.dart';
import 'package:consumir_api/screens/purchases_list.dart';
import 'package:consumir_api/screens/products_list.dart';
import 'package:flutter/material.dart';

class NavegationDrawer extends StatelessWidget {
  final bool showMenu;
  final bool centerTitle;

  const NavegationDrawer({Key? key, this.showMenu = true, this.centerTitle = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkTheme ? Colors.white : Colors.black;

    return 
    Drawer(

      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Color.fromRGBO(102, 51, 153, 1)
                  :  Color.fromARGB(29, 10, 105, 112),
            ),
            child: Center(
              child: Image.asset('assets/img/logo.png', height: 150, color: Colors.grey[350]),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: iconColor),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminScreen()),
              );
            },
          ),
        
          if (showMenu)
            ListTile(
              leading: Icon(Icons.exit_to_app, color: iconColor),
              title: const Text('Cerrar sesión'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text('¿Estás seguro de que deseas cerrar la sesión?'),
                      actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            child: const Text('Sí'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Cerrar el diálogo
                              Navigator.of(context).pop();
                            },
                            child: const Text('No', style: TextStyle(color: Colors.red)),
                          ),
                    ],
                    
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
