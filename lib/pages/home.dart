import 'package:flutter/material.dart';
import 'package:pixa/pages/full_screen.dart';
import 'package:pixa/services/api/pexel_api.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List images = [];
  int page = 1;
  String searchKey = '';
  String nextPage = '';
  late TextEditingController _controller;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchImages();
    _controller = TextEditingController();
    scrollController.addListener(() async {
      if (scrollController.position.atEdge) {
        bool isTop = scrollController.position.pixels == 0;
        if (isTop) {
          print('At the top');
        } else {
          if (nextPage.isNotEmpty) {
            final List result = await PexelApi.loadMoreImages(nextPage);
            setState(() {
              images.addAll(result[0]);
            });
            nextPage = result[1];
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  fetchImages() async {
    final List result = await PexelApi.getImages();
    setState(() {
      images = result[0];
    });
    nextPage = result[1];
  }

  searchImages({required String searchKey}) async {
    final result = await PexelApi.searchImages(searchKey: searchKey);
    setState(() {
      images = result[0];
    });
    nextPage = result[1];
  }

  Color getAvgColor(String avgColor) {
    final String colorString = '0xff${avgColor.substring(1)}';
    final int colorInt = int.parse(colorString);
    return Color(colorInt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // IconButton(
                  //   onPressed: () {
                  //     scaffoldKey.currentState!.openDrawer();
                  //   },
                  //   icon: const Icon(Icons.menu),
                  // ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(color: Color(0xff6f6f6f)),
                        onSubmitted: (String value) async {
                          final result =
                              await PexelApi.searchImages(searchKey: searchKey);
                          setState(() {
                            images = result[0];
                          });
                          nextPage = result[1];
                        },
                        controller: _controller,
                        onChanged: (value) => setState(() {
                          searchKey = value;
                        }),
                        cursorColor: const Color(0xff167869),
                        decoration: InputDecoration(
                            fillColor: const Color(0xfff3f3f3),
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8),
                            ),

                            // labelText: 'Search',
                            hintText: 'Search for amazing content',
                            hintStyle:
                                const TextStyle(color: Color(0xffbdbdbd)),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Color(0xffbdbdbd)),
                            suffixIcon: searchKey.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    color: const Color(0xffbdbdbd),
                                    onPressed: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      setState(() {
                                        _controller.clear();
                                        searchKey = '';
                                      });
                                    },
                                  )
                                : const SizedBox()),
                      ),
                    ),
                  ),
                  searchKey.isNotEmpty
                      ? InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            final result = await PexelApi.searchImages(
                                searchKey: searchKey);
                            setState(() {
                              images = result[0];
                            });
                            nextPage = result[1];
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Search',
                              style: TextStyle(
                                  color: Color(0xff729f7e), fontSize: 16),
                            ),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                triggerMode: RefreshIndicatorTriggerMode.onEdge,
                onRefresh: () async {
                  //TODO
                },
                child: GridView.builder(
                    controller: scrollController,
                    itemCount: images.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 2,
                            crossAxisCount: 3,
                            childAspectRatio: 2 / 3,
                            mainAxisSpacing: 2),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreen(
                                  image: images[index]
                                  // imageurl: images[index]['src']['large2x'],
                                  // id: images[index]['id'].toString(),
                                  // avgColor: images[index]['avg_color'],
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: getAvgColor(images[index]['avg_color']),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              images[index]['src']['large'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Whoops!',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xff167869),
          onPressed: () {
            scrollController.animateTo(
              0,
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
            );
          },
          child: const Icon(
            Icons.arrow_upward,
            color: Colors.white,
          )),
    );
  }
}
