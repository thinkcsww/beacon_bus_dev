import 'dart:async';

import 'package:beacon_bus/models/children.dart';
import 'package:beacon_bus/screens/teacher/widgets/alarm.dart';
import 'package:beacons/beacons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'tab_base.dart';

class RangingTab extends ListTab {

  String _busNum;
  String _className;
  int check = 0;
  List<Children> userResults = [];

  Alarm alarm = new Alarm();

  RangingTab.origin() {
    this._busNum = '';
    this._className = '';
  }
  RangingTab(String busNum, String className) {
    if(busNum == '') {
      this._busNum = null;
    } else {
      this._busNum = busNum;
    }
    if(className == '') {
      this._className = null;
    } else {
      this._className = className;
    }
  }

  @override
  Stream<ListTabResult> stream(BeaconRegion region) {
    Firestore.instance
        .collection('Kindergarden')
        .document('hamang')
        .collection('Children')
        .where('busNum', isEqualTo: _busNum)
        .where('classRoom', isEqualTo: _className)
        .snapshots()
        .forEach((data) {
      data.documents.forEach((data) {
        var userdata = Children.fromSnapshot(data);
        userResults.add(userdata);
      });
    });
    return Beacons.ranging(
      region: region,
      inBackground: false,
    ).map((result) {
      if (result.isSuccessful) {
        for (var data in userResults) {
          for (var beacon in result.beacons) {
            if (beacon.ids[1].toString() == data.beaconMajor &&
                beacon.ids[2].toString() == data.beaconMinor &&
                beacon.ids[0] == "fda50693-a4e2-4fb1-afcf-c6eb07647825" &&
                beacon.distance < 5) {
              data.link = true;
              break;
            } else {
              data.link = false;
            }
          }
        }
        if(_className == null && _busNum != null) {
          for (var data in userResults) {
            print(userResults);
            if (data.link == true) {
              data.connectTime++;
              data.noConnectTime = 0;
              if (data.connectTime == 10) {
                Firestore.instance
                    .collection('Kindergarden')
                    .document('hamang')
                    .collection('Children')
                    .document(data.id)
                    .updateData({'boardState': 'board'});
                alarm.showNotification(int.parse(data.beaconMajor), data.name + '이 승차했습니다.');
              }
            } else {
              data.noConnectTime++;
              data.connectTime = 0;
              if (data.boardState == 'board') {
                if (data.noConnectTime == 10) {
                  data.boardState = 'unknown';
                  Firestore.instance
                      .collection('Kindergarden')
                      .document('hamang')
                      .collection('Children')
                      .document(data.id)
                      .updateData({'boardState': 'unknown'});
                  alarm.showNotification(int.parse(data.beaconMajor), data.name + '이 하차했습니다.');
                }
              }
            }
          }
        } else if(_className != null && _busNum == null){
          for (var data in userResults) {
            print(userResults);
            if (data.link == true) {
              data.connectTime++;
              data.noConnectTime = 0;
              if (data.connectTime == 10) {
                Firestore.instance
                    .collection('Kindergarden')
                    .document('hamang')
                    .collection('Children')
                    .document(data.id)
                    .updateData({'activityState': 'in'});
                alarm.showNotification(int.parse(data.beaconMajor), data.name + '이 범위로 들어왔습니다.');
              }
            } else {
              data.noConnectTime++;
              data.connectTime = 0;
              if (data.activityState == 'in') {
                if (data.noConnectTime == 10) {
                  data.activityState = 'out';
                  Firestore.instance
                      .collection('Kindergarden')
                      .document('hamang')
                      .collection('Children')
                      .document(data.id)
                      .updateData({'activityState': 'out'});
                  alarm.showNotification(int.parse(data.beaconMajor), data.name + '이 범위를 이탈했습니다.');
                }
              }
            }
          }
        }
      }
      return ListTabResult(
        isSuccessful: result.isSuccessful,
      );
    });
  }
}