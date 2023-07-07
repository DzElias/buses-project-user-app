import 'package:flutter/material.dart';

class StopWidget extends StatelessWidget {
  final bool onn;
  final String directionName;
  final List<int> time;

  const StopWidget(
      {Key? key,
      required this.onn,
      required this.directionName,
      required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              (time[0] != -1)
                  ? time[1] != 0
                      ? "${getTime(time[0], time[1], context)}"
                      : "Llegando"
                  : "Ya paso",
              style: const TextStyle(color: Colors.black54, fontSize: 11),
            ),
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Icon(
                Icons.location_on,
                color: onn ? Colors.blueAccent : Colors.grey,
                size: 35,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(directionName,
                  style: TextStyle(
                      fontFamily: 'Betm-Medium',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: onn ? Colors.black87 : Colors.black54)),
            ],
          ),
          const Spacer(),
          // onn
          //     ? InkWell(
          //         onTap: () {},
          //         child: Icon(
          //           Icons.notification_add,
          //           color: Colors.black54,
          //           size: 30,
          //         ))
          //     : SizedBox()
        ],
      ),
    );
  }
}

getTime(int hours, int min, BuildContext context) {
  TimeOfDay time = TimeOfDay.now().add(hour: hours, minute: min);

  return time.format(context);
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay add({int hour = 0, int minute = 0}) {
    for (int i = 0; ((this.minute + minute) >= 60); i++) {
      hour++;
      minute = minute - (60 - this.minute);
    }

    if (this.hour + hour >= 24) {
      hour = -(this.hour) + ((this.hour + hour) - 24);
    }

    return replacing(
        hour: ((this.hour + hour) != 0) ? (this.hour + hour) : null,
        minute: ((this.minute + minute) > 0) ? this.minute + minute : null);
  }
}
