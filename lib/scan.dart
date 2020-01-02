import 'dart:io';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  String result = '';
  final TextEditingController _textController = TextEditingController();

  Future barcodeScanning() async {
    try {
      String result = await BarcodeScanner.scan();
      setState(() => this.result = result);
      _textController.text = result;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.result = 'No camera permission!';
        });
      } else {
        setState(() => this.result = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.result = 'Nothing captured.');
    } catch (e) {
      setState(() => this.result = 'Unknown error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Reader'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: Container(child: buildBookList()),
          ),
          _buildBody()
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Flexible(
      child: TextField(
        controller: _textController,
      ),
    );
  }

  Container _buildBody() {
    return Container(
      child: Row(
        children: <Widget>[
          RaisedButton(
              child: Text('Scan Barcode'),
              onPressed: () {
                barcodeScanning();
              }),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget buildBookList() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('books').limit(3).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['title']),
                  subtitle: new Text(document['circleName']),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
