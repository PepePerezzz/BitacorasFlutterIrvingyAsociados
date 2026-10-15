import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/incidencia.dart';

class AlmacenLocal {
  // CAMBIO: inicializa preferencias solo al usarlas para evitar crear el plugin antes de tiempo.
  late final prefs = SharedPreferencesAsync();
  final clave = 'nexasoft_incidencias_v1';

  Future<List<Incidencia>> leer() async {
    final guardadas = await prefs.getString(clave);
    final texto = guardadas ??
        await rootBundle.loadString('assets/data/incidencias.json');
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) => Incidencia.desdeJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> guardar(List<Incidencia> lista) async {
    final datos = lista.map((x) => x.toJson()).toList();
    await prefs.setString(clave, jsonEncode(datos));
  }

  Future<void> restaurarDatosDeEjemplo() async {
    await prefs.remove(clave);
  }
}
