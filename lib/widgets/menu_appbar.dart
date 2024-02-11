import 'package:consumir_api/main.dart';
import 'package:flutter/material.dart';

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
    final iconColor = isDarkTheme ? Colors.white : Colors.black;

    return AppBar(
      backgroundColor: isDarkTheme
          ? Color.fromARGB(29, 10, 105, 112)
          : Color.fromRGBO(102, 51, 153, 1),
      title: Center(
        child: Image.asset('assets/img/logo.png', height: 100, color: Colors.grey[400]),
      ),
      actions: [
        IconButton(
          onPressed: () {
            final myapp = MyApp.of(context);
            if (myapp != null) {
              myapp.changeTheme();
            }
          },
          icon: Theme.of(context).brightness == Brightness.light
              ? Icon(Icons.dark_mode, color: iconColor) // Color del ícono ajustado aquí
              : Icon(Icons.light_mode, color: iconColor), // Color del ícono ajustado aquí
        )
      ],
    );
  }
}
