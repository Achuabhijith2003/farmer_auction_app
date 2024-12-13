import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';

class Payments extends StatefulWidget {
  final amount;
  const Payments({super.key, required this.amount});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  String? _upiAddrError;
  final _upiAddressController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isUpiEditable = false;
  List<ApplicationMeta>? _apps;

  @override
  void initState() {
    super.initState();
    _upiAddressController.text =
        "achuabhijith495@okhdfcbank"; // Provide a test UPI ID here.
    _amountController.text = "${widget.amount}";

    _fetchUpiApps();
  }

  Future<void> _fetchUpiApps() async {
    try {
      final apps = await UpiPay.getInstalledUpiApplications(
          statusType: UpiApplicationDiscoveryAppStatusType.all);
      setState(() {
        _apps = apps;
      });
    } catch (e) {
      print("Error fetching UPI apps: $e");
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiAddressController.dispose();
    super.dispose();
  }

  void _generateAmount() {
    setState(() {
      _amountController.text =
          (Random.secure().nextDouble() * 10).toStringAsFixed(2);
    });
  }

  Future<void> _onTap(ApplicationMeta app) async {
    final err = _validateUpiAddress(_upiAddressController.text);
    if (err != null) {
      setState(() {
        _upiAddrError = err;
      });
      return;
    }
    setState(() {
      _upiAddrError = null;
    });

    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    try {
      final result = await UpiPay.initiateTransaction(
        amount: _amountController.text,
        app: app.upiApplication,
        receiverName: 'JR',
        receiverUpiAddress: _upiAddressController.text,
        transactionRef: transactionRef,
        transactionNote: 'UPI Payment',
      );
      print("Transaction result: $result");
    } catch (e) {
      print("Error during transaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("UPI Payment "),
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: <Widget>[
            // _vpa(),
            if (_upiAddrError != null) _vpaError(),
            _amount(),
            const Divider(),
            const Center(child: Text("Select an UPI app to pay")),
            const Divider(),
            if (Platform.isIOS) _submitButton(),
            if (Platform.isAndroid) _androidApps(),
          ],
        ),
      ),
    );
  }

  Widget _vpa() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: _upiAddressController,
              enabled: _isUpiEditable,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'address@upi',
                labelText: 'Receiving UPI Address',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(
                _isUpiEditable ? Icons.check : Icons.edit,
              ),
              onPressed: () {
                setState(() {
                  _isUpiEditable = !_isUpiEditable;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _vpaError() {
    return Container(
      margin: const EdgeInsets.only(top: 4, left: 12),
      child: Text(
        _upiAddrError!,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _amount() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _amountController,
              readOnly: true,
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount',
              ),
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.only(left: 8),
          //   child: IconButton(
          //     icon: const Icon(Icons.loop),
          //     onPressed: _generateAmount,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: MaterialButton(
              onPressed: _apps != null && _apps!.isNotEmpty
                  ? () async => await _onTap(_apps!.first)
                  : null,
              color: Theme.of(context).colorScheme.secondary,
              height: 48,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              child: Text('Initiate Transaction',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _androidApps() {
    if (_apps == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apps!.isEmpty) {
      return const Text('No UPI apps installed.');
    }
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _apps!
          .map(
            (app) => InkWell(
              onTap: () async => await _onTap(app),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  app.iconImage(48),
                  Text(app.upiApplication.getAppName()),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

String? _validateUpiAddress(String value) {
  if (value.isEmpty) {
    return 'UPI VPA is required.';
  }
  if (value.split('@').length != 2) {
    return 'Invalid UPI VPA';
  }
  return null;
}
