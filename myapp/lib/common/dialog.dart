import 'package:flutter/material.dart';

class AllDialog {
  callMonoInputDialog(BuildContext context, String textTitle, String textField,
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

    callInfoDialog(BuildContext context, String textTitle, String textContent, Function onValidation) {
        showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: Text(textTitle),
          content: Text(textContent),
          elevation: 24.0,
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                onValidation();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Never'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

}