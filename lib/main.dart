// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'web-view-container.dart';

void main() => runApp(MyApp());

// #docregion MyApp
class MyApp extends StatelessWidget {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ingredients List',
      theme: ThemeData(
        primaryColor: Colors.lightGreen[300],
      ),
      home: IngredientsList(),
    );
  }
  // #enddocregion build
}
// #enddocregion MyApp

// #docregion RWS-var
class _IngredientsListState extends State<IngredientsList> {
  final _suggestions = <String>[
    "Apple",
    "Apricot",
    "Asparagus",
    "Banana",
    "Bacon",
    "Beef",
    "Beef Brisket",
    "Beef Shank",
    "Beef Sirloin",
    "Beef Tenderloin",
    "Blackberry",
    "Bread",
    "Broccoli",
    "Carrots",
    "Celery",
    "Cheese",
    "Chicken",
    "Chicken Breast",
    "Chicken Thigh",
    "Coconut",
    "Corn",
    "Crab",
    "Cucumber",
    "Date",
    "Eggs",
    "Eggplant",
    "Fig",
    "Garlic",
    "Ginger",
    "Gooseberry",
    "Grapes",
    "Ground Beef",
    "Grouper",
    "Lamb",
    "Lamb Shank",
    "Lemon",
    "Lettuce",
    "Litchi",
    "Mango",
    "Milk",
    "Mushcroom",
    "Onion",
    "Orange",
    "Papaya",
    "Peach",
    "Peas",
    "Pepper",
    "Pineapple",
    "Pomegranate",
    "Pork",
    "Pork Chop",
    "Potato",
    "Rice",
    "Salmon",
    "Sausage",
    "Shrimp",
    "Spinach",
    "Squash",
    "Starfruit",
    "Steak",
    "Tomato",
    "Tuna",
  ];
  final _saved = List<String>();
  final _biggerFont = TextStyle(fontSize: 18.0);

  // #enddocregion RWS-var

  // #docregion _buildSuggestions
  // creating a visual list from the array above
  Widget _buildSuggestions() {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/
          final index = i ~/ 2; /*3*/
          return _buildRow(_suggestions[index]);
        });
  }
  // #enddocregion _buildSuggestions

  // #docregion _buildRow
  // building each row for each item in list


  Widget _buildRow(String pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }

        });
      },
    );
  }
  // #enddocregion _buildRow

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingredients List'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
          IconButton(icon: Icon(Icons.fastfood), onPressed: _recipeGet)
        ],
      ),
      body: _buildSuggestions(),
    );
  }
  // #enddocregion RWS-build


  // concatenating all the list inputs into string
  String _savedToInput(List<String> _savedList){
    
    var _savedIn = "";
    _savedList.forEach((element) {
      _savedIn = _savedIn + " " + element;
    });

    print(_savedIn);

    return _savedIn;
  }

  
  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          final tiles = _saved.map(
            (String pair) {
              return ListTile(
                title: Text(
                  pair,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('My Leftovers'),
            ),
            body: ListView(children: divided),
          );
        }, //...to here.
      ),
    );
  }
  // #docregion RWS-var

  void _recipeGet(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Recipe List'),
            ),
            body: Container(
              child: FutureBuilder<List<dynamic>>(
                future: fetchRecipe(),
                builder: (BuildContext context, AsyncSnapshot snapshot){

                  // renders list once the information has returned
                  if(snapshot.hasData){
                    return ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index){
                        return
                          Card(
                            child: Column(
                              children: <Widget>[
                                ListTile( // the recipe buttons
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(snapshot.data[index]['recipe']['image'])),
                                  title: Text(_name(snapshot.data[index])),
                                  subtitle: Text(_source(snapshot.data[index])),
                                  onTap: (){    // when you tap the recipe, it opens the URL
                                    
                                    _openBrowser(context, _link(snapshot.data[index]));
                                    //_launchInApp(_link(snapshot.data[index]));
                                  }
                                )
                              ],
                            ),
                          );
                      }
                    );
                   }else { // if no data, show circular progress indicator
                      return Center(child: CircularProgressIndicator());
                   }
                }
              )
            )
          );
        }
      )
    );
  }



  // code related to fetching recipes from the API
  static String appID = 'ca262cad';
  static String appKey = '80a6270fab856b53a824b49196589ad7';


  // fetching the data from the API
  Future<List<dynamic>> fetchRecipe() async {

    String _savedInput = _savedToInput(_saved);
    String apiUrl = 'https://api.edamam.com/search?q=' + _savedInput + '&app_id=' + appID + '&app_key=' + appKey + '&from=0&to=10';

    var result = await http.get(apiUrl);    // data fetched from the apiURL
    return json.decode(result.body)['hits'];
  }

  // returns the recipe name
  String _name(dynamic recipe){
    return recipe['recipe']['label'];
  }

  // returns source of recipe i.e. website
  String _source(dynamic recipe){
    return recipe['recipe']['source'];
  }

  // returns the recipe URL
  String _link(dynamic recipe){
    return recipe['recipe']['url'];
  }


  void _openBrowser(BuildContext context, String url){
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => WebViewContainer(url))
    );
  }
  
}
// #enddocregion RWS-var

class IngredientsList extends StatefulWidget {
  @override
  State<IngredientsList> createState() => _IngredientsListState();
}























