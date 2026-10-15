import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  // CAMBIO: permite inyectar el almacén para pruebas y conserva el almacén local por defecto.
  final AlmacenLocal datos;
  List<Incidencia> incidencias = [];
  int cantidadPendientes = 0;

  GestorIncidencias({AlmacenLocal? datos}) : datos = datos ?? AlmacenLocal();

  Future<void> iniciar() async {
    incidencias = await datos.leer();
    _actualizarConteoPendientes();
  }

  // CAMBIO: busca sin distinguir mayúsculas en ID, título, descripción y demás datos visibles.
  List<Incidencia> buscar(String texto) {
    final consulta = texto.trim().toLowerCase();
    if (consulta.isEmpty) return incidencias;
    return incidencias.where((x) {
      final campos = [
        x.id,
        x.titulo,
        x.descripcion,
        x.cliente,
        x.categoria,
        x.estado,
      ];
      return campos.any((campo) => campo.toLowerCase().contains(consulta));
    }).toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    if (estado == 'Pendiente') return cantidadPendientes;
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        // CAMBIO: guarda el nuevo estado y actualiza el contador inmediatamente.
        _actualizarConteoPendientes();
        await datos.guardar(incidencias);
        break;
      }
    }
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      fecha: DateTime.now().toIso8601String().split('T').first,
    );
    incidencias.insert(0, nuevo);
    _actualizarConteoPendientes();
    await datos.guardar(incidencias);
  }

  void _actualizarConteoPendientes() {
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
