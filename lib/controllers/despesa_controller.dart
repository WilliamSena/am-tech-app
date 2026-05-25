import 'package:am_tech/services/despesa_service.dart';
import '../models/despesa_model.dart';

class DespesaController {
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _service = DespesaService();

  final String collection = 'despesas';

  Future<void> cadastrarDespesa(Despesa despesa) async {
    _service.criar(despesa);
  }

  Stream<List<Despesa>> listarDespesas() {
    return _service.listarDespesas();
  }
}