import 'package:flutter/material.dart';

class InputDialog {
  createAlertDialog(BuildContext context, String textTitle, String textField,
      Function onValidation) {
    TextEditingController nameController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('$textTitle'),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: textField),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Save'),
                onPressed: () {
                  onValidation(nameController.text);
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
