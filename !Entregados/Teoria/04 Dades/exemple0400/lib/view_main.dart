import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class ViewMain extends StatelessWidget {
  const ViewMain({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final double topPadding =
        MediaQuery.of(context).padding.top + kMinInteractiveDimensionCupertino;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('JSON Editor'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: topPadding), // Afegeix el padding necessari
            Expanded(
              child: SingleChildScrollView(
                child: CupertinoTextField(
                  controller: appData.jsonController,
                  maxLines: null,
                  placeholder: 'JSON Content',
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: CupertinoColors.systemGrey, width: 0.5),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CupertinoButton(
                  onPressed: () async {
                    if (kDebugMode) {
                      print("Loading file...");
                    }
                    await appData.loadFileWithPicker();
                  },
                  color: CupertinoColors.activeBlue,
                  child: const Text('Load'),
                ),
                CupertinoButton(
                  onPressed: appData.fileLoaded
                      ? () async {
                          await appData.saveLoadedFile();
                        }
                      : null,
                  color: appData.fileLoaded
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.inactiveGray,
                  child: const Text('Save'),
                ),
                CupertinoButton(
                  onPressed: appData.fileLoaded
                      ? () async {
                          await appData.saveFileWithPicker();
                        }
                      : null,
                  color: appData.fileLoaded
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.inactiveGray,
                  child: const Text('Save As'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
