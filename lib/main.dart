import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:servidor/AddPhoto.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teste Request Servidor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeWidget(),
    );
  }
}

//? ------------------------------------------------------------------------------
//! ------------------------------------------------------------------------------
//? ------------------------------------------------------------------------------
//! ------------------------------------------------------------------------------
//? ------------------------------------------------------------------------------
//! ------------------------------------------------------------------------------

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  GlobalKey<ScaffoldState> _keyScaffold = GlobalKey();
  bool _isLogar = false;

  void infoSnackBar(String text) {
    final SnackBar snack = SnackBar(
      backgroundColor: Colors.white,
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red,
          fontSize: 18,
          fontFamily: "Courier New",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    _keyScaffold.currentState.showSnackBar(snack);
  }

  Future<bool> verifyUser() async {
    String id = _idController.text.trim();
    String name = _nameController.text.trim();

    String url = "http://testemaxleco.atwebpages.com/verifyUser.php";
    http.Response response;

    Map<String, dynamic> user = {
      "id": id,
      "name": name,
    };
    response = await http.post(url, body: user);

    var resultAux = json.decode(response.body);
    List<dynamic> result = [resultAux];

    if (result[0]["Result"] == "User has account") {
      return true;
    } else {
      print(result[0]["Result"]);
      return false;
    }
  }

  void _logar(bool value) {
    if (value == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ListUsers()),
        (route) => false,
      );
    } else {
      infoSnackBar("Dados Incorretos!");
      _isLogar = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("LOGIN"),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(36),
          child: Column(
            children: [
              TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "ID",
                ),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "NAME",
                ),
              ),
              SizedBox(height: 50),
              FutureBuilder<bool>(
                initialData: false,
                future: _isLogar == false
                    ? null
                    : verifyUser().then((value) {
                        _logar(value);
                        return;
                      }),
                builder: (context, snapshot) {
                  // Widget Botão
                  Widget button;
                  Widget btnEntrar = RaisedButton(
                    onPressed: () async {
                      // ------------------------------------------
                      if (_idController.text.isEmpty ||
                          _nameController.text.isEmpty) {
                        infoSnackBar("Preencha todos os campos!");
                        return;
                      } else {
                        setState(() {
                          _isLogar = true;
                        });
                      }
                    },
                    child: Text(
                      'ENTRAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Colors.blueAccent,
                  );

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      button = CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      );
                      break;
                    default:
                      button = btnEntrar;
                      break;
                  }
                  return button;
                },
              ),
              SizedBox(height: 30),
              RaisedButton(
                onPressed: () async {
                  String id = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CadastrarUser()),
                  );
                  setState(() {
                    _idController.text = id;
                  });
                },
                child: Text(
                  'REGISTRE-SE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//? ------------------------------------------------------------------------------
//! ------------------------------------------------------------------------------
//? ------------------------------------------------------------------------------
//! ------------------------------------------------------------------------------
//? ------------------------------------------------------------------------------
//! ------------------------------------------------------------------------------

class CadastrarUser extends StatefulWidget {
  @override
  _CadastrarUserState createState() => _CadastrarUserState();
}

class _CadastrarUserState extends State<CadastrarUser> {
  TextEditingController _nameController = TextEditingController();
  GlobalKey<ScaffoldState> _keyScaffold = GlobalKey();
  bool _isLogar = false;
  String _id = "0";

  void infoSnackBar(String text, {Color cor = Colors.red}) {
    final SnackBar snack = SnackBar(
      backgroundColor: Colors.white,
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: cor,
          fontSize: 18,
          fontFamily: "Courier New",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    _keyScaffold.currentState.showSnackBar(snack);
  }

  Future<bool> registerUser() async {
    String name = _nameController.text.trim();

    String url = "http://testemaxleco.atwebpages.com/include.php";
    http.Response response;

    Map<String, dynamic> user = {
      "name": name,
    };
    response = await http.post(url, body: user);

    var resultAux = json.decode(response.body);
    List<dynamic> result = [resultAux];

    if (result[0]["Result"] == "Registered") {
      _id = result[0]["id"].toString();
      return true;
    } else {
      print(result[0]["Result"]);
      return false;
    }
  }

  void _cadastrar(bool value) {
    if (value == true) {
      infoSnackBar("Cadastrado com sucesso! ID: $_id", cor: Colors.green);
      Navigator.pop(context, _id);
    } else {
      infoSnackBar("Não foi possivel cadastrar!");
      _isLogar = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _keyScaffold,
      appBar: AppBar(
        title: Text("Cadastro de Usuários"),
      ),
      body: Center(
        child: Container(
          width: size.width * 0.7,
          height: size.height * 0.5,
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "NAME",
                ),
              ),
              SizedBox(height: 50),
              FutureBuilder<bool>(
                initialData: false,
                future: _isLogar == false
                    ? null
                    : registerUser().then((value) {
                        _cadastrar(value);
                        return;
                      }),
                builder: (context, snapshot) {
                  // Widget Botão
                  Widget button;
                  Widget btnEntrar = RaisedButton(
                    onPressed: () async {
                      if (_nameController.text.isEmpty) {
                        infoSnackBar("Preencha o campo!");
                        return;
                      } else {
                        setState(() {
                          _isLogar = true;
                        });
                      }
                    },
                    child: Text(
                      'CADASTRAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Colors.blueAccent,
                  );

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      button = CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      );
                      break;
                    default:
                      button = btnEntrar;
                      break;
                  }
                  return button;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//? ------------------------------------------------------------------------------
//! ------------------------------------------------------------------------------
//? ------------------------------------------------------------------------------
//! ------------------------------------------------------------------------------
//? ------------------------------------------------------------------------------
//! ------------------------------------------------------------------------------

class ListUsers extends StatefulWidget {
  @override
  _ListUsersState createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  Future<List> _listUsers() async {
    String url = "http://testemaxleco.atwebpages.com/index.php";
    http.Response response;
    response = await http.get(url);

    List<dynamic> result = json.decode(response.body);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Usuários"),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder(
          future: _listUsers(),
          builder: (context, snapshot) {
            Widget widgetUsers;
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                widgetUsers = Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
                break;
              case ConnectionState.none:
                widgetUsers = Center(
                  child: Text("Error"),
                );
                break;
              case ConnectionState.active:
                break;
              case ConnectionState.done:
                List users = snapshot.data;
                widgetUsers = ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(users[index]["name"]),
                        subtitle: Text(users[index]["id"].toString()),
                      );
                    });
                break;
              default:
                widgetUsers = Container();
            }
            return widgetUsers;
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPhoto()
            ),
          );
        },
      ),
    );
  }
}
