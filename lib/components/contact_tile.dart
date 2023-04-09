import 'package:flutter/material.dart';

class ContactTile extends StatefulWidget {
  const ContactTile(
      {super.key,
      required this.value,
      required this.onChanged,
      required this.title,
      required this.contactIcon});

  final bool? value;
  final ValueChanged<bool?> onChanged;
  final String title;
  final IconData contactIcon;

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  final FocusNode contactTilefocusNode =
      FocusNode(descendantsAreFocusable: false);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      focusNode: contactTilefocusNode,
      dense: true,
      title: Text(widget.title),
      secondary: Icon(widget.contactIcon),
      value: widget.value,
      onChanged: widget.onChanged,
    );
  }

  @override
  void dispose() {
    contactTilefocusNode.dispose();
    super.dispose();
  }
}
