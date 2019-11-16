import 'package:flutter/material.dart';

import 'package:upi_india/upi_india.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:quiz/custom_widgets/top_bar.dart';

class Registration extends StatefulWidget {
  final Map<String, dynamic> user;

  Registration({@required this.user});

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  Future _initiateTransaction;
  String txnId = '';
  String txnRef = '';
  String approvalRef = '';
  String status = '';

  Future<String> initTransaction(String app) async {
    UpiIndia upi = new UpiIndia(
      app: app,
      receiverUpiId: '9439717907@paytm',
      receiverName: 'SOLE',
      transactionRefId: 'AnWeshaN2020',
      transactionNote: 'Registration for Anweshan 2020',
      amount: 50.00,
    );

    String response = await upi.startTransaction();

    return response;
  }

  Future<bool> registerUser() {
    return Firestore.instance
        .collection('registered')
        .where('email', isEqualTo: widget.user['email'])
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      print(snapshot.documents.length);
      if (snapshot.documents.length == 0) {
        return Firestore.instance.collection('registered').add({
          'name': widget.user['name'],
          'photoUrl': widget.user['photoUrl'],
          'email': widget.user['email'],
          'txnId': txnId,
          'status': status,
          'approvalRefNumber': approvalRef,
        }).then((value) {
          return true;
        }).catchError((error) {
          return false;
        });
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _instructionBody = Container(
      child: Text(
        'This is the registration for Anweshan 2020. After completing the payment you ' +
            'will get your transaction details. Be sure to keep a copy of the ' +
            'details for future queries. Please stay online during the transaction and do not ' +
            'press the back button. For any query contact our support team.',
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );

    Widget _paymentBody = Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Pay using :',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        SizedBox(
          height: 25.0,
        ),
        Wrap(
          direction: Axis.horizontal,
          spacing: 0.0,
          runSpacing: 30.0,
          children: <Widget>[
            FlatButton(
              child: ClipOval(
                child: Image.asset(
                  'images/phonepe.jpg',
                  height: 60.0,
                  width: 60.0,
                ),
              ),
              shape: CircleBorder(),
              onPressed: () {
                _initiateTransaction = initTransaction(UpiIndiaApps.PhonePe);
                setState(() {});
              },
            ),
            FlatButton(
              child: ClipOval(
                child: Image.asset(
                  'images/paytm.jpg',
                  height: 60.0,
                  width: 60.0,
                ),
              ),
              shape: CircleBorder(),
              onPressed: () {
                _initiateTransaction = initTransaction(UpiIndiaApps.PayTM);
                setState(() {});
              },
            ),
            FlatButton(
              child: ClipOval(
                child: Image.asset(
                  'images/gpay.jpg',
                  height: 60.0,
                  width: 60.0,
                ),
              ),
              shape: CircleBorder(),
              onPressed: () {
                _initiateTransaction = initTransaction(UpiIndiaApps.GooglePay);
                setState(() {});
              },
            ),
            FlatButton(
              child: ClipOval(
                child: Image.asset(
                  'images/bhim.jpg',
                  height: 60.0,
                  width: 60.0,
                ),
              ),
              shape: CircleBorder(),
              onPressed: () {
                _initiateTransaction = initTransaction(UpiIndiaApps.BHIMUPI);
                setState(() {});
              },
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Center(
          child: FutureBuilder(
            future: _initiateTransaction,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              TextStyle _textStyle =
                  TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500);
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null)
                return Text(' ');
              else {
                print(snapshot.data.toString());
                switch (snapshot.data.toString()) {
                  case UpiIndiaResponseError.APP_NOT_INSTALLED:
                    return Text(
                      'App not installed.',
                      style: _textStyle,
                    );
                    break;
                  case UpiIndiaResponseError.INVALID_PARAMETERS:
                    return Text(
                      'Requested app rejected to proceed further.',
                      style: _textStyle,
                    );
                    break;
                  case UpiIndiaResponseError.USER_CANCELLED:
                    return Text(
                      'It seems like you cancelled the transaction.',
                      style: _textStyle,
                    );
                    break;
                  case UpiIndiaResponseError.NULL_RESPONSE:
                    return Text(
                      'No data received',
                      style: _textStyle,
                    );
                    break;
                  default:
                    UpiIndiaResponse _flutterUpiResponse;
                    _flutterUpiResponse = UpiIndiaResponse(snapshot.data);
                    txnId = _flutterUpiResponse.transactionId;
                    txnRef = _flutterUpiResponse.transactionRefId;
                    status = _flutterUpiResponse.status;
                    approvalRef = _flutterUpiResponse.approvalRefNo;
                    print(status);
                    if (status == UpiIndiaResponseStatus.SUCCESS) {
                      return FutureBuilder(
                        future: registerUser(),
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasError)
                              return Text(
                                'Error occured during registration. Contact Support.',
                                style: _textStyle,
                              );
                            else if (snapshot.data) {
                              return Column(
                                children: <Widget>[
                                  Text(
                                    'Registered Succesfully!',
                                    style: _textStyle,
                                  ),
                                  FlatButton(
                                    child: Text('See Transaction Summary'),
                                    textColor: Colors.green,
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              _TransactionSummary(
                                            txnId: txnId,
                                            txnRef: txnRef,
                                            approvalRef: approvalRef,
                                            status: status,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            } else {
                              return Text(
                                'Failed to register. Contact Support.',
                                style: _textStyle,
                              );
                            }
                          }
                          return CircularProgressIndicator();
                        },
                      );
                    } else if (status == UpiIndiaResponseStatus.SUBMITTED) {
                      return Text(
                        'Looks like your transaction didn\'t complete. Cancel it or contact support',
                        style: _textStyle,
                      );
                    } else {
                      return Text(
                        'Payment Failed',
                        style: _textStyle,
                      );
                    }
                }
              }
            },
          ),
        ),
      ],
    ));

    // return Stack(
    //   children: <Widget>[
    //     Image.asset(
    //       'images/background.jpg',
    //       fit: BoxFit.cover,
    //       height: MediaQuery.of(context).size.height,
    //       width: MediaQuery.of(context).size.width,
    //       alignment: Alignment.bottomCenter,
    //     ),
    return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.lightBlue[300],
                Colors.lightBlue[100],
                Colors.white,
              ],
            ),
          ),
        child:Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TopBar(
            title: 'Registration',
            active: GestureDetector(
              child: Container(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 18.0,
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          body: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Instructions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                _instructionBody,
                SizedBox(
                  height: 20,
                ),
                _paymentBody,
              ],
            ),
          ),
        ),
      // ],
    );
  }
}

class _TransactionSummary extends StatelessWidget {
  final String txnId, txnRef, approvalRef, status;

  _TransactionSummary({
    this.approvalRef,
    this.status,
    this.txnId,
    this.txnRef,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle _summaryHead =
            TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),
        _summaryText = TextStyle(fontSize: 16.0);

    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                'images/sole_logo.png',
                height: 150,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Transaction ID:',
              style: _summaryHead,
            ),
            SizedBox(
              height: 5.0,
            ),
            SelectableText(
              txnId ?? " ",
              style: _summaryText,
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'Transaction Reference ID:',
              style: _summaryHead,
            ),
            SizedBox(
              height: 5.0,
            ),
            SelectableText(
              txnRef ?? " ",
              style: _summaryText,
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'Transaction Status:',
              style: _summaryHead,
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              status.toUpperCase() ?? " ",
              style: _summaryText,
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
