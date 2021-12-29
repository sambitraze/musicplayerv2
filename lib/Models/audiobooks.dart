// To parse this JSON data, do
//
//     final audioBook = audioBookFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<AudioBook> audioBookFromJson(String str) => List<AudioBook>.from(json.decode(str).map((x) => AudioBook.fromJson(x)));

String audioBookToJson(List<AudioBook> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AudioBook {
    AudioBook({
        required this.id,
        required this.status,
        required this.dateCreated,
        required this.name,
        required this.publisher,
        required this.author,
        required this.tags,
        required this.cover,
        required this.description,
        required this.audiolists,
        required this.category,
        required this.reader,
    });

    int id;
    String status;
    DateTime dateCreated;
    String name;
    String publisher;
    String author;
    List<String> tags;
    String cover;
    String description;
    List<Audiolist> audiolists;
    Category category;
    Reader reader;

    factory AudioBook.fromJson(Map<String, dynamic> json) => AudioBook(
        id: json["id"],
        status: json["status"],
        dateCreated: DateTime.parse(json["date_created"]),
        name: json["name"],
        publisher: json["publisher"],
        author: json["author"],
        tags: List<String>.from(json["tags"].map((x) => x)),
        cover: json["cover"],
        description: json["description"],
        audiolists: List<Audiolist>.from(json["audiolists"].map((x) => Audiolist.fromJson(x["audiofile_id"]))),
        category: Category.fromJson(json["category"]),
        reader: Reader.fromJson(json["reader"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "date_created": dateCreated.toIso8601String(),
        "name": name,
        "publisher": publisher,
        "author": author,
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "cover": cover,
        "description": description,
        "audiolists": List<dynamic>.from(audiolists.map((x) => x.toJson())),
        "category": category.toJson(),
        "reader": reader.toJson(),
    };
}

class Audiolist {
    Audiolist({
        required this.id,
        required this.title,
        required this.hour,
        required this.minutes,
        required this.seconds,
        required this.file,
    });

    String id;
    String title;
    String hour;
    String minutes;
    String seconds;
    String file;

    factory Audiolist.fromJson(Map<String, dynamic> json) => Audiolist(
        id: json["id"],
        title: json["title"],
        hour: json["hour"],
        minutes: json["minutes"],
        seconds: json["seconds"],
        file: json["file"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "hour": hour,
        "minutes": minutes,
        "seconds": seconds,
        "file": file,
    };
}

class Category {
    Category({
        required this.id,
        required this.name,
        required this.type,
        required this.cover,
    });

    int id;
    String name;
    String type;
    String cover;

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        cover: json["cover"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "cover": cover,
    };
}

class Reader {
    Reader({
        required this.id,
        required this.status,
        required this.name,
        required this.followers,
        required this.email,
        required this.cover,
    });

    int id;
    String status;
    String name;
    int followers;
    String email;
    String cover;

    factory Reader.fromJson(Map<String, dynamic> json) => Reader(
        id: json["id"],
        status: json["status"],
        name: json["name"],
        followers: json["followers"],
        email: json["email"],
        cover: json["cover"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "name": name,
        "followers": followers,
        "email": email,
        "cover": cover,
    };
}
