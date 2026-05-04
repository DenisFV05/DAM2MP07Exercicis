import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'add_form.dart';
import 'app_data.dart';

class ViewWidget extends StatefulWidget {
  const ViewWidget({super.key});

  @override
  ViewWidgetState createState() => ViewWidgetState();
}

class ViewWidgetState extends State<ViewWidget> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Animals Database'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<AppData>(
                builder: (context, appData, child) {
                  return ListView.builder(
                    itemCount: appData.animals.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: const BoxDecoration(
                            color: CupertinoColors.systemGrey4,
                            border: Border(
                              bottom: BorderSide(
                                color: CupertinoColors.separator,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Espècie',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Longevitat',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Número de Potes',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width:
                                    75, // Espai per a la columna del botó Eliminar
                                child: Center(
                                  child: Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final animal = appData.animals[index - 1];
                      final isEvenRow = index % 2 == 1;
                      final isSelected = animal == appData.selectedAnimal;
                      final backgroundColor = isSelected
                          ? CupertinoColors.systemYellow.withOpacity(0.5)
                          : (isEvenRow
                              ? CupertinoColors.white
                              : CupertinoColors.lightBackgroundGray);

                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            appData.selectAnimal(null);
                          } else {
                            appData.selectAnimal(animal);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            border: const Border(
                              bottom: BorderSide(
                                color: CupertinoColors.separator,
                              ),
                            ),
                          ),
                          constraints: const BoxConstraints(minHeight: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  animal.especie,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Longevitat: ${animal.longevitat}',
                                  style: const TextStyle(fontSize: 12.0),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Potes: ${animal.numeropotes}',
                                  style: const TextStyle(fontSize: 12.0),
                                ),
                              ),
                              SizedBox(
                                width: 75,
                                child: isSelected
                                    ? Center(
                                        child: CDKButton(
                                          onPressed: () {
                                            appData.deleteSelected();
                                          },
                                          child: const Text('Eliminar'),
                                        ),
                                      )
                                    : Container(), // Mantenir l'espai en blanc
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const AddAnimalForm(),
          ],
        ),
      ),
    );
  }
}
