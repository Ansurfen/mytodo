import 'package:flutter/material.dart';

class TimelineDots {
  TimelineDots({required this.context});

  BuildContext context;

  factory TimelineDots.of(BuildContext context) {
    return TimelineDots(context: context);
  }

  Widget get simple {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: null,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget get borderDot {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          image: null,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border.all()),
    );
  }

  Widget get icon {
    return Icon(Icons.event);
  }

  Widget get section {
    return Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: Colors.black,
        image: null,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget get circleIcon {
    return InkWell(
        onTap: () {
          print(666);
        },
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.all(
              Radius.circular(64),
            ),
          ),
          child: const Icon(
            Icons.calendar_month,
            color: Colors.white,
          ),
        ));
  }

  Widget get sectionHighlighted {
    return Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: null,
        shape: BoxShape.circle,
      ),
    );
  }
}
