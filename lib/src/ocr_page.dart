import 'dart:io';

import 'package:docify/src/edit_text.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OcrPage extends StatefulWidget {
  @override
  _OcrPageState createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  File _imageFile;
  VisionText _text;
  TextRecognizer recogniser;

  @override
  void initState() {
    super.initState();
    recogniser = FirebaseVision.instance.textRecognizer();
  }

  @override
  void dispose() {
    recogniser.close();
    super.dispose();
  }

  void _getImageAndDetectText() async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (imageFile == null) return;
    final image = FirebaseVisionImage.fromFile(imageFile);
    final text = await recogniser.processImage(image);

    if (mounted) {
      setState(() {
        _text = text;
        _imageFile = imageFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Docify"),
      ),
      body: _imageFile == null
          ? Container()
          : ImageAndText(imageFile: _imageFile, text: _text),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectText,
        tooltip: 'Pick an image',
        child: Icon(Icons.add_photo_alternate),
      ),
    );
  }
}

class ImageAndText extends StatelessWidget {
  ImageAndText({@required this.imageFile, @required this.text});

  final File imageFile;
  final VisionText text;

  List<Rect> _getBoundingBoxes() {
    List<Rect> ret = [];
    if (text != null) {
      for (var block in text.blocks) {
        for (var line in block.lines) {
          for (var elem in line.elements) {
            ret.add(elem.boundingBox);
          }
        }
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ButtonBar(
          children: <Widget>[
            OutlineButton(
              child: Text("Extract Text"),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => EditText(text: text),
                ),
              ),
            ),
          ],
        ),
        Stack(
          children: <Widget>[
            Container( 
              child: Image.file(
                imageFile,
              ),
            ),
          ]..addAll(
              _getBoundingBoxes()
                  .map(
                    (b) => Positioned.fromRect(
                      rect: b,
                      child: Container(
                        constraints: BoxConstraints.expand(),
                        foregroundDecoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ),
      ],
    );
  }
}

class TextCoordinates extends StatelessWidget {
  TextCoordinates({@required this.block});

  final TextBlock block;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          '(${block.boundingBox.top}, ${block.boundingBox.left}, ${block.boundingBox.bottom}, ${block.boundingBox.right})'),
      subtitle: Text('Text: ${block.text}, Lines: ${block.lines.length}'),
    );
  }
}
