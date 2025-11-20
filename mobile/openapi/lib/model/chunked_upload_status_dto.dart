//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChunkedUploadStatusDto {
  /// Returns a new [ChunkedUploadStatusDto] instance.
  ChunkedUploadStatusDto({
    required this.chunkSize,
    this.chunksReceived = const [],
    required this.complete,
    required this.createdAt,
    required this.fileSize,
    required this.filename,
    required this.totalChunks,
    required this.updatedAt,
    required this.uploadId,
  });

  /// Chunk size
  num chunkSize;

  /// Chunks received so far
  List<num> chunksReceived;

  /// Whether upload is complete
  bool complete;

  /// Upload created timestamp
  DateTime createdAt;

  /// Total file size
  num fileSize;

  /// Original filename
  String filename;

  /// Total chunks
  num totalChunks;

  /// Last updated timestamp
  DateTime updatedAt;

  /// Upload session ID
  String uploadId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChunkedUploadStatusDto &&
    other.chunkSize == chunkSize &&
    _deepEquality.equals(other.chunksReceived, chunksReceived) &&
    other.complete == complete &&
    other.createdAt == createdAt &&
    other.fileSize == fileSize &&
    other.filename == filename &&
    other.totalChunks == totalChunks &&
    other.updatedAt == updatedAt &&
    other.uploadId == uploadId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (chunkSize.hashCode) +
    (chunksReceived.hashCode) +
    (complete.hashCode) +
    (createdAt.hashCode) +
    (fileSize.hashCode) +
    (filename.hashCode) +
    (totalChunks.hashCode) +
    (updatedAt.hashCode) +
    (uploadId.hashCode);

  @override
  String toString() => 'ChunkedUploadStatusDto[chunkSize=$chunkSize, chunksReceived=$chunksReceived, complete=$complete, createdAt=$createdAt, fileSize=$fileSize, filename=$filename, totalChunks=$totalChunks, updatedAt=$updatedAt, uploadId=$uploadId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'chunkSize'] = this.chunkSize;
      json[r'chunksReceived'] = this.chunksReceived;
      json[r'complete'] = this.complete;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'fileSize'] = this.fileSize;
      json[r'filename'] = this.filename;
      json[r'totalChunks'] = this.totalChunks;
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
      json[r'uploadId'] = this.uploadId;
    return json;
  }

  /// Returns a new [ChunkedUploadStatusDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChunkedUploadStatusDto? fromJson(dynamic value) {
    upgradeDto(value, "ChunkedUploadStatusDto");
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return ChunkedUploadStatusDto(
        chunkSize: num.parse('${json[r'chunkSize']}'),
        chunksReceived: json[r'chunksReceived'] is Iterable
            ? (json[r'chunksReceived'] as Iterable).cast<num>().toList(growable: false)
            : const [],
        complete: mapValueOfType<bool>(json, r'complete')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        fileSize: num.parse('${json[r'fileSize']}'),
        filename: mapValueOfType<String>(json, r'filename')!,
        totalChunks: num.parse('${json[r'totalChunks']}'),
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
        uploadId: mapValueOfType<String>(json, r'uploadId')!,
      );
    }
    return null;
  }

  static List<ChunkedUploadStatusDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChunkedUploadStatusDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChunkedUploadStatusDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChunkedUploadStatusDto> mapFromJson(dynamic json) {
    final map = <String, ChunkedUploadStatusDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChunkedUploadStatusDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChunkedUploadStatusDto-objects as value to a dart map
  static Map<String, List<ChunkedUploadStatusDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChunkedUploadStatusDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChunkedUploadStatusDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'chunkSize',
    'chunksReceived',
    'complete',
    'createdAt',
    'fileSize',
    'filename',
    'totalChunks',
    'updatedAt',
    'uploadId',
  };
}

