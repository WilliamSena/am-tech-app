import 'package:am_tech/controllers/veiculo_controller.dart';
import 'package:flutter/material.dart';

class VeiculoView extends StatelessWidget{
  final controller = VeiculoController();

  VeiculoView({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Veiculos'),),
    );
  }
}