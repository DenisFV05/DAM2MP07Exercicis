import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_button.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_field_text.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'animals_model.dart';

class AddAnimalForm extends StatefulWidget {
  const AddAnimalForm({super.key});

  @override
  AddAnimalFormState createState() => AddAnimalFormState();
}

class AddAnimalFormState extends State<AddAnimalForm> {
  final _especieController = TextEditingController();
  final _longevitatController = TextEditingController();
  final _potesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: CDKFieldText(
              controller: _especieController,
              placeholder: 'Espècie',
              keyboardType: TextInputType.text,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CDKFieldText(
              controller: _longevitatController,
              placeholder: 'Longevitat',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CDKFieldText(
              controller: _potesController,
              placeholder: 'Número de Potes',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 8),
          CDKButton(
            onPressed: () {
              final animal = AnimalsModel(
                especie: _especieController.text,
                longevitat: int.parse(_longevitatController.text),
                numeropotes: int.parse(_potesController.text),
              );
              context.read<AppData>().addAnimal(animal);
              _especieController.clear();
              _longevitatController.clear();
              _potesController.clear();
            },
            child: const Text('Afegir'),
          ),
        ],
      ),
    );
  }
}
