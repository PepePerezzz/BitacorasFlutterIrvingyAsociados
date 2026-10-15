import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/data/almacen_local.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';

// CAMBIO: pruebas de regresión para búsqueda, recuento y guardado del estado.
class AlmacenEnMemoria extends AlmacenLocal {
  AlmacenEnMemoria(this.semilla);

  final List<Incidencia> semilla;
  List<Incidencia>? guardadas;

  @override
  Future<List<Incidencia>> leer() async => guardadas ?? semilla;

  @override
  Future<void> guardar(List<Incidencia> lista) async {
    guardadas = lista.map((x) => Incidencia.desdeJson(x.toJson())).toList();
  }
}

Incidencia crearIncidencia({String estado = 'Pendiente'}) => Incidencia(
      id: 'INC-101',
      titulo: 'Impresora del almacén no responde',
      descripcion: 'Los documentos permanecen en cola.',
      cliente: 'Almacenes del Centro',
      categoria: 'Hardware',
      estado: estado,
      fecha: '2026-10-14',
    );

void main() {
  test('la búsqueda ignora mayúsculas y revisa los campos de la incidencia',
      () {
    final gestor = GestorIncidencias();
    gestor.incidencias = [crearIncidencia()];

    expect(gestor.buscar('  IMPRESORA ').map((x) => x.id), ['INC-101']);
    expect(gestor.buscar('almacenes').map((x) => x.id), ['INC-101']);
    expect(gestor.buscar('hardware').map((x) => x.id), ['INC-101']);
    expect(gestor.buscar('sin coincidencia'), isEmpty);
  });

  test('cambiar el estado actualiza el contador y persiste el cambio',
      () async {
    final almacen = AlmacenEnMemoria([crearIncidencia()]);
    final gestor = GestorIncidencias(datos: almacen);
    await gestor.iniciar();
    expect(gestor.cantidadPendientes, 1);

    await gestor.cambiarEstado('INC-101', 'Resuelta');

    expect(gestor.cantidadPendientes, 0);
    expect(almacen.guardadas?.single.estado, 'Resuelta');

    final gestorAlReabrir = GestorIncidencias(datos: almacen);
    await gestorAlReabrir.iniciar();
    expect(gestorAlReabrir.porId('INC-101')?.estado, 'Resuelta');
  });
}
