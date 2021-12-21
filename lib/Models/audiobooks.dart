import 'dart:convert';

List<AudioBook> audioBookFromJson(String str) => List<AudioBook>.from(json.decode(str).map((x) => AudioBook.fromJson(x)));

String audioBookToJson(List<AudioBook> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AudioBook {
    AudioBook({
        required this.id,
        required this.status,
        required this.dateCreated,
        required this.dateUpdated,
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
    DateTime dateUpdated;
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
        dateUpdated: DateTime.parse(json["date_updated"]),
        name: json["name"],
        publisher: json["publisher"],
        author: json["author"],
        tags: List<String>.from(json["tags"].map((x) => x)),
        cover: json["cover"],
        description: json["description"],
        audiolists: List<Audiolist>.from(json["audiolists"].map((x) => Audiolist.fromJson(x))),
        category: Category.fromJson(json["category"]),
        reader: Reader.fromJson(json["reader"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "date_created": dateCreated.toIso8601String(),
        "date_updated": dateUpdated.toIso8601String(),
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
        required this.audioBooksId,
        required this.directusFilesId,
    });

    int id;
    int audioBooksId;
    String directusFilesId;

    factory Audiolist.fromJson(Map<String, dynamic> json) => Audiolist(
        id: json["id"],
        audioBooksId: json["AudioBooks_id"],
        directusFilesId: json["directus_files_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "AudioBooks_id": audioBooksId,
        "directus_files_id": directusFilesId,
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
        required this.dateCreated,
        required this.dateUpdated,
        required this.name,
        required this.followers,
        required this.email,
        required this.cover,
    });

    int id;
    String status;
    DateTime dateCreated;
    dynamic dateUpdated;
    String name;
    int followers;
    String email;
    String cover;

    factory Reader.fromJson(Map<String, dynamic> json) => Reader(
        id: json["id"],
        status: json["status"],
        dateCreated: DateTime.parse(json["date_created"]),
        dateUpdated: json["date_updated"],
        name: json["name"],
        followers: json["followers"],
        email: json["email"],
        cover: json["cover"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "date_created": dateCreated.toIso8601String(),
        "date_updated": dateUpdated,
        "name": name,
        "followers": followers,
        "email": email,
        "cover": cover,
    };
}
