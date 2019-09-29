import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditText extends StatelessWidget {
  final VisionText text;

  EditText({@required this.text});

  List<Widget> _getPositionedSelectable() {
    List<Widget> ret = [];
    if (text != null) {
      for (var block in text.blocks) {
        for (var line in block.lines){
          ret.add(
            Positioned(
              child: SelectableText(
                line.text,
                style: TextStyle(fontSize: 19.0),
                scrollPhysics: NeverScrollableScrollPhysics(),
              ),
              top: line.boundingBox.top,
              left: line.boundingBox.left,
            ),
          );
        }
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    print(text.text);
    return Scaffold(
      appBar: AppBar(
        title: Text("Docify"),
      ),
      body: Center(
        child: Column(
          verticalDirection: VerticalDirection.up,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonBar(
                children: <Widget>[
                  OutlineButton(
                    splashColor: Colors.blueAccent,
                    child: Text("Copy All"),
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: text.text)),
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: Stack(children: _getPositionedSelectable()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
