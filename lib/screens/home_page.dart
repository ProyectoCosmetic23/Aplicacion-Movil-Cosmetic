import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../dominio/models/imagen_list.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 50),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Distribuidora Monvel',
                style: TextStyle(
                  color: const Color.fromRGBO(102, 51, 153, 1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '!Control de stock de productos agotados!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
            ),
            items: imageSliders,
          ),
          Align(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.all(50.0),
                  child: const Text(
                    'Cosmetic aplicacion para la distribucion de productos de belleza de la empresa DISTRIBUIDORA MONVEL ubicada en el centro comercial Oriente, bodega 507 en la ciudad de Medellín, Antioquia. Está dedicada a la distribución de productos cosméticos y aseo personal y se desempeña hace 10 años.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
