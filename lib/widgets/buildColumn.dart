import 'package:flutter/material.dart';

class BuildColumn extends StatefulWidget {
  final header;
  final text;
  const BuildColumn({Key? key,required this.header, required this.text }) : super(key: key);

  @override
  State<BuildColumn> createState() => _BuildColumnState();
}

class _BuildColumnState extends State<BuildColumn> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.header,style: TextStyle(fontWeight: FontWeight.bold),),
        Text(widget.text),
      ],
    );
  }
}
