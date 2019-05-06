import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BoardStateWidget extends StatelessWidget {
  final Color color;
  final String busNum;
  final String changeStateItem;

  BoardStateWidget({this.color, this.busNum, this.changeStateItem});

  @override
  Widget build(BuildContext context) {
    if (busNum == "notboard") {
      return Container(
        width: 300.0,
        height: 300.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150.0),
          color: color,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Image.asset(
                  'images/background.JPG',
                  width: 100.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Text('개인 이동', style: TextStyle(color: Colors.black, fontSize: 18.0),),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: 300.0,
        height: 300.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150.0),
          color: color,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Image.asset(
                  'images/background.JPG',
                  width: 100.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: FutureBuilder<DocumentSnapshot>(
                  future: Firestore.instance.collection('Kindergarden')
                      .document('hamang').collection('Bus').document(
                      "$busNum호차")
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Text('...');
                    String teacher = snapshot.data.data['teacher'];
                    return Text('$teacher 선생님', style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),);
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text('$changeStateItem', style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Text('탑승중', style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),),
            ),
          ],
        ),
      );
    }
  }
}