// // lib/screens/qr_code_scanner_screen.dart
// import 'package:doan_flutter/screens/transfer_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
//
// class QrCodeScannerScreen extends StatefulWidget {
//   @override
//   _QrCodeScannerScreenState createState() => _QrCodeScannerScreenState();
// }
//
// class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       controller.pauseCamera();
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TransferScreen(prefilledAccountNumber: scanData.code),
//         ),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scan QR Code'),
//       ),
//       body: QRView(
//         key: qrKey,
//         onQRViewCreated: _onQRViewCreated,
//       ),
//     );
//   }
// }