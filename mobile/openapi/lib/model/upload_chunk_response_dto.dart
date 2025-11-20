//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UploadChunkResponseDto {
  /// Returns a new [UploadChunkResponseDto] instance.
  UploadChunkResponseDto({
    required this.chunkIndex,
    required this.chunksReceived,
    required this.complete,
    required this.totalChunks,
    required this.uploadId,
  });

  /// Chunk index that was uploaded
  num chunkIndex;

  /// Total chunks received so far
  num chunksReceived;

  /// Whether all chunks have been received
  bool complete;

  /// Total chunks expected
  num totalChunks;

  /// Upload session ID
  String uploadId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UploadChunkResponseDto &&
    other.chunkIndex == chunkIndex &&
    other.chunksReceived == chunksReceived &&
    other.complete == complete &&
    other.totalChunks == totalChunks &&
    other.uploadId == uploadId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (chunkIndex.hashCode) +
    (chunksReceived.hashCode) +
    (complete.hashCode) +
    (totalChunks.hashCode) +
    (uploadId.hashCode);

  @override
  String toString() => 'UploadChunkResponseDto[chunkIndex=$chunkIndex, chunksReceived=$chunksReceived, complete=$complete, totalChunks=$totalChunks, uploadId=$uploadId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'chunkIndex'] = this.chunkIndex;
      json[r'chunksReceived'] = this.chunksReceived;
      json[r'complete'] = this.complete;
      json[r'totalChunks'] = this.totalChunks;
      json[r'uploadId'] = this.uploadId;
    return json;
  }

  /// Returns a new [UploadChunkResponseDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UploadChunkResponseDto? fromJson(dynamic value) {
    upgradeDto(value, "UploadChunkResponseDto");
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return UploadChunkResponseDto(
        chunkIndex: num.parse('${json[r'chunkIndex']}'),
        chunksReceived: num.parse('${json[r'chunksReceived']}'),
        complete: mapValueOfType<bool>(json, r'complete')!,
        totalChunks: num.parse('${json[r'totalChunks']}'),
        uploadId: mapValueOfType<String>(json, r'uploadId')!,
      );
    }
    return null;
  }

  static List<UploadChunkResponseDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UploadChunkResponseDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UploadChunkResponseDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UploadChunkResponseDto> mapFromJson(dynamic json) {
    final map = <String, UploadChunkResponseDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UploadChunkResponseDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UploadChunkResponseDto-objects as value to a dart map
  static Map<String, List<UploadChunkResponseDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UploadChunkResponseDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UploadChunkResponseDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'chunkIndex',
    'chunksReceived',
    'complete',
    'totalChunks',
    'uploadId',
  };
}

