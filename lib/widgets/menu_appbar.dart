import 'package:flutter/material.dart';
import 'package:consumir_api/main.dart';

class MenuAppbar extends StatefulWidget implements PreferredSizeWidget {
  final bool showMenu;
  final bool centerTitle;

  const MenuAppbar({Key? key, this.showMenu = true, this.centerTitle = false})
      : super(key: key);

  @override
  State<MenuAppbar> createState() => _MenuAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

class _MenuAppbarState extends State<MenuAppbar> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDarkTheme
          ? Color.fromARGB(29, 10, 105, 112)
          : Color.fromRGBO(102, 51, 153, 1),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Alineación de la fila a la izquierda
        crossAxisAlignment: CrossAxisAlignment.center, // Alineación de la fila verticalmente
        children: [
          SizedBox(width: 100), // Espacio adicional antes de la imagen
          Image.asset('assets/img/logo.png', height: 100, color: Colors.grey[400]),
        ],
      ),
      automaticallyImplyLeading: false, // Esto elimina la flecha hacia atrás
      actions: [
        IconButton(
          onPressed: () {
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
          icon: Icon(Icons.exit_to_app, color: Colors.white), // Icono de cerrar sesión
        ),
      ],
    );
  }
}
