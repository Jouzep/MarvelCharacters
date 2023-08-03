import 'package:flutter/material.dart';
import 'marvelApiCommunication.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();

  runApp(const MyApp());
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Center(child: Text("Marvel Universe")),
      backgroundColor: Colors.red,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MyBody extends StatelessWidget {
  const MyBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: const Center(
        child: Column(
          children: [
            MySearchBar(),
            HeroesList(),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: "Marvel hero",
        home: Scaffold(
          appBar: MyAppBar(),
          body: MyBody(),
        ));
  }
}

class MySearchBar extends StatefulWidget {
  const MySearchBar({super.key});

  @override
  _MySearchBar createState() => _MySearchBar();
}

class _MySearchBar extends State<MySearchBar> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: TextField(
          controller: _textEditingController,
          onSubmitted: (value) {
            print('Submitted: $value');
          },
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: 'Find your super hero',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _textEditingController.clear();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class HeroesList extends StatefulWidget {
  const HeroesList({super.key});

  @override
  _HeroesList createState() => _HeroesList();
}

class _HeroesList extends State<HeroesList> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> characters = [];
  int offset = 0;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _getCharacters();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    int tmp = (_scrollController.offset) as int;
    int tmpoffset = (tmp ~/ 100) + 1;
    if (tmpoffset % 10 == 0) {
      if (offset < tmpoffset) {
        offset = tmpoffset;
        _getCharacters();
      }
    }
  }

  void _getCharacters() async {
    final marvelApi = MarvelApi();
    final data = await marvelApi.getAllCharacters(offset);
    setState(() {
      List<dynamic> tmpCharacters = data['results'];
      characters.addAll(tmpCharacters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            controller: _scrollController,
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final singleCharacter = characters[index];
              return SingleHero(character: singleCharacter);
            }));
  }
}

class SingleHero extends StatelessWidget {
  final Map<String, dynamic> character;
  const SingleHero({required this.character, Key? key}) : super(key: key);

  void alertDialog(BuildContext context, Map<String, dynamic> character) {
    String description = character['description'] = character['description'];
    if (character['description'].length < 1) {
      description =
          'Oups, it seems that there is no info about this super hero...';
    }
    var alert = AlertDialog(
      title: Text(character['name']),
      content: Text(description),
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0), // Set the border radius
        ),
        child: ListTile(
          title: Text(character['name']),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              character['thumbnail']['path'] +
                  '.' +
                  character['thumbnail']['extension'],
            ),
          ),
          onTap: () => alertDialog(context, character),
        ),
      ),
    );
  }
}
