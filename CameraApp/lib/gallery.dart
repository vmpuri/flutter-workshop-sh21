import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:async';

class ImageSelector extends StatefulWidget {
  ImageSelector({Key key, @required this.album}) : super(key: key);
  final AssetPathEntity album;

  @override
  _ImageSelectorState createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  List<AssetEntity> photos;

  Widget getPhoto(int index) {
    if (index > this.photos.length) {
      widget.album
          .getAssetListRange(start: index, end: index + 1)
          .then((value) {
        value.forEach((el) {
          photos.add(el);
        });
      });
    }
    return (index <= photos.length)
        ? InkResponse(
            child: Container(child: Builder(
              builder: (BuildContext context) {
                return GridTile(
                  child: FutureBuilder<Uint8List>(
                      future: photos[index].thumbDataWithSize(150, 150),
                      builder: (BuildContext context,
                          AsyncSnapshot<Uint8List> snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(snapshot.data);
                        } else
                          return Center(child: Text('Loading'));
                      }),
                  //Image.file(image),
                  footer: Container(
                    color: Colors.blue[200],
                    child: Center(
                      child: Text(
                        (photos.length >= index) ? photos[index].title : '',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            )),
          )
        : Text('Loading...');
  }

  @override
  void initState() {
    super.initState();
    this.photos = [];
    widget.album.getAssetListRange(start: 0, end: 6).then((value) {
      setState(() {
        value.forEach((v) {
          photos.add(v);
        });
      });
      print(photos[0].title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.album.name),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Builder(builder: (BuildContext context) {
          return (GridView.builder(
            itemBuilder: (context, index) => getPhoto(index),
            itemCount: (photos.isEmpty) ? 0 : widget.album.assetCount,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 1,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              maxCrossAxisExtent: 300,
            ),
          ));
        }),
      ),
    );
  }
}

class AlbumSelector extends StatefulWidget {
  @override
  _AlbumSelectorState createState() => _AlbumSelectorState();
}

class _AlbumSelectorState extends State<AlbumSelector> {
  List<AssetPathEntity> albums;

  @override
  void initState() {
    super.initState();

    this.albums = [];
    PhotoManager.requestPermission().then((value) {
      if (value) {
      } else {
        PhotoManager.openSetting();
      }
    });
    PhotoManager.getAssetPathList().then((l) {
      setState(() {
        this.albums = l;
      });
    });
  }

  Widget getAlbum(index) {
    return (index <= albums.length)
        ? InkResponse(
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) =>
                          new ImageSelector(album: albums[index])));
            },
            child: Container(
              color: Colors.blue[50],
              child: GridTile(
                child: Icon(Icons.folder),
                footer: Container(
                  color: Colors.blue[200],
                  child: Center(
                    child: Text(
                      albums[index].name,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Null;
  }

  @override
  Widget build(BuildContext context) {
    return (GridView.builder(
      itemBuilder: (context, index) => getAlbum(index),
      itemCount: (albums.isEmpty) ? 0 : albums.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        childAspectRatio: 1,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        maxCrossAxisExtent: 350,
      ),
    ));
  }
}
