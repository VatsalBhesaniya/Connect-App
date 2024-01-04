import 'package:connect/common/constants.dart';
import 'package:flutter/material.dart';

class GenderRadioGroup extends StatefulWidget {
  const GenderRadioGroup(
      {Key? key, required this.groupValue, required this.onChanged})
      : super(key: key);
  final Gender groupValue;
  final Function(Gender?)? onChanged;

  @override
  State<GenderRadioGroup> createState() => _GenderRadioGroupState();
}

class _GenderRadioGroupState extends State<GenderRadioGroup> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _buildRadioButton(Gender.male),
        _buildRadioButton(Gender.female),
      ],
    );
  }

  Widget _buildRadioButton(Gender radioValue) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Radio<Gender>(
            value: radioValue,
            groupValue: widget.groupValue,
            onChanged: widget.onChanged,
          ),
          Text(radioValue.title),
        ],
      ),
    );
  }
}
