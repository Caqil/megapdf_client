// lib/data/models/folder_model.dart
import 'package:equatable/equatable.dart';

class FolderModel extends Equatable {
  final int? id;
  final String name;
  final String path;
  final int? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FolderModel({
    this.id,
    required this.name,
    required this.path,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'],
      name: map['name'],
      path: map['path'],
      parentId: map['parent_id'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'parent_id': parentId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  FolderModel copyWith({
    int? id,
    String? name,
    String? path,
    int? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, path, parentId, createdAt, updatedAt];
}
