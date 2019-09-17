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
  ValueNotifier<int> _index = ValueNotifier(0);
  StepState step0 = StepState.indexed,
      step1 = StepState.indexed,
      step2 = StepState.indexed;

  Future<String> initTransaction(String app) async {
    UpiIndia upi = new UpiIndia(
      app: app,
      receiverUpiId: '9078600498@ybl',
      receiverName: 'MdAzharuddin',
      transactionRefId: 'AnWeshaN2020',
      transactionNote: 'Registration for Anweshan 2020',
      amount: 1.00,
    );

    String response = await upi.startTransaction();

    return response;
  }

  Future<bool> registerUser() {
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

  @override
  Widget build(BuildContext context) {
    Widget _instructionBody = Container(
      child: Column(
        children: <Widget>[
          Text(
            'This is the registration for Anweshan 2020. After completing the payment you ' +
                'will get your transaction details. Please be sure to keep a screenshot of the ' +
                'details for future queries. Please stay online during the transaction and do not ' +
                'press the back button. For any query contact our support team.',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                child: Text('Next'),
                textColor: Colors.green,
                onPressed: () {
                  step0 = StepState.complete;
                  _index.value = 1;
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                textColor: Colors.red,
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        ],
      ),
    );

    Widget _paymentBody = Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
          runSpacing: 32.0,
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
        SizedBox(height: 25.0),
        FutureBuilder(
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
                    'Requested payment is invalid.',
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
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
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
                                  child: Text('Transaction Summary'),
                                  textColor: Colors.green,
                                  onPressed: () {
                                    step1 = StepState.complete;
                                    step2 = StepState.complete;
                                    _index.value = 2;
                                    setState(() {});
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
                    return Text('Payment Failed', style: _textStyle,);
                  }
              }
            }
          },
        ),
      ],
    ));

    TextStyle _summaryHead =
            TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),
        _summaryText = TextStyle(fontSize: 16.0);

    Widget _paymentSummaryBody = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Transaction ID:',
          style: _summaryHead,
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
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
        Text(
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
    );

    Widget _body = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ValueListenableBuilder(
        valueListenable: _index,
        builder: (BuildContext context, int index, Widget child) {
          return Stepper(
            steps: [
              Step(
                title: Text('Instruction'),
                content: _instructionBody,
                state: step0,
                isActive: true,
              ),
              Step(
                title: Text('Payment'),
                content: _paymentBody,
                state: step1,
                isActive: true,
              ),
              Step(
                title: Text('Payment Summary'),
                state: step2,
                isActive: true,
                content: _paymentSummaryBody,
              ),
            ],
            currentStep: index,
            controlsBuilder: (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
                Container(),
          );
        },
      ),
    );

    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue[200],
              Colors.lightBlue[100],
              Colors.white
            ],
          ),
        ),
        child: _body,
      ),
    );
  }
}
