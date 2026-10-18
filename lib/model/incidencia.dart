class Incidencia {
  // CAMBIO: conserva prioridad Media al leer o crear incidencias sin prioridad.
  static const prioridadesValidas = ['Baja', 'Media', 'Alta'];
  String id;
  String titulo;
  String descripcion;
  String cliente;
  String categoria;
  String estado;
  String fecha;
  String prioridad;

  Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cliente,
    required this.categoria,
    required this.estado,
    required this.fecha,
    // CAMBIO: compatibilidad con registros previos al FEAT-001.
    this.prioridad = 'Media',
  });

  factory Incidencia.desdeJson(Map<String, dynamic> m) {
    return Incidencia(
      id: m['id']?.toString() ?? '',
      titulo: m['titulo']?.toString() ?? '',
      descripcion: m['descripcion']?.toString() ?? '',
      cliente: m['cliente']?.toString() ?? '',
      categoria: m['categoria']?.toString() ?? 'Software',
      estado: m['estado']?.toString() ?? 'Pendiente',
      fecha: m['fecha']?.toString() ?? '',
      // CAMBIO: los datos antiguos o inválidos se migran de forma segura a Media.
      prioridad: prioridadesValidas.contains(m['prioridad']?.toString())
          ? m['prioridad'].toString()
          : 'Media',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'cliente': cliente,
      'categoria': categoria,
      'estado': estado,
      'fecha': fecha,
      // CAMBIO: incluye prioridad en la persistencia local.
      'prioridad': prioridad,
    };
  }
}
