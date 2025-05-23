// lib/data/models/file_folder_link.dart
import 'package:equatable/equatable.dart';

class FileFolderLink extends Equatable {
  final int? id;
  final String filePath;
  final String fileName;
  final int folderId;
  final DateTime addedAt;
  final Map<String, dynamic>? metadata;

  const FileFolderLink({
    this.id,
    required this.filePath,
    required this.fileName,
    required this.folderId,
    required this.addedAt,
    this.metadata,
  });

  factory FileFolderLink.fromMap(Map<String, dynamic> map) {
    return FileFolderLink(
      id: map['id'],
      filePath: map['file_path'],
      fileName: map['file_name'],
      folderId: map['folder_id'],
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['added_at']),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_path': filePath,
      'file_name': fileName,
      'folder_id': folderId,
      'added_at': addedAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  FileFolderLink copyWith({
    int? id,
    String? filePath,
    String? fileName,
    int? folderId,
    DateTime? addedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FileFolderLink(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      folderId: folderId ?? this.folderId,
      addedAt: addedAt ?? this.addedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props =>
      [id, filePath, fileName, folderId, addedAt, metadata];
}
