import 'dart:io';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  String result = '';

  Future barcodeScanning() async {
    try {
      String result = await BarcodeScanner.scan();
      setState(() => this.result = result);
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
      body: _buildBody(),
    );
  }

  Container _buildBody() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                  child: Text('Scan Barcode'),
                  onPressed: () {
                    barcodeScanning();
                  }),
              Padding(
                padding: EdgeInsets.all(16.0),
              ),
              Text('Result : $result'),
            ],
          ),
        ],
      ),
    );
  }
}