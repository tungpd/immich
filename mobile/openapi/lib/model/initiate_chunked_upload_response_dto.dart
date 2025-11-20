//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InitiateChunkedUploadResponseDto {
  /// Returns a new [InitiateChunkedUploadResponseDto] instance.
  InitiateChunkedUploadResponseDto({
    required this.chunkSize,
    required this.uploadId,
  });

  /// Chunk size to use for uploads
  num chunkSize;

  /// Unique upload session ID
  String uploadId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InitiateChunkedUploadResponseDto &&
    other.chunkSize == chunkSize &&
    other.uploadId == uploadId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (chunkSize.hashCode) +
    (uploadId.hashCode);

  @override
  String toString() => 'InitiateChunkedUploadResponseDto[chunkSize=$chunkSize, uploadId=$uploadId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'chunkSize'] = this.chunkSize;
      json[r'uploadId'] = this.uploadId;
    return json;
  }

  /// Returns a new [InitiateChunkedUploadResponseDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InitiateChunkedUploadResponseDto? fromJson(dynamic value) {
    upgradeDto(value, "InitiateChunkedUploadResponseDto");
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return InitiateChunkedUploadResponseDto(
        chunkSize: num.parse('${json[r'chunkSize']}'),
        uploadId: mapValueOfType<String>(json, r'uploadId')!,
      );
    }
    return null;
  }

  static List<InitiateChunkedUploadResponseDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InitiateChunkedUploadResponseDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InitiateChunkedUploadResponseDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InitiateChunkedUploadResponseDto> mapFromJson(dynamic json) {
    final map = <String, InitiateChunkedUploadResponseDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InitiateChunkedUploadResponseDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InitiateChunkedUploadResponseDto-objects as value to a dart map
  static Map<String, List<InitiateChunkedUploadResponseDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InitiateChunkedUploadResponseDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InitiateChunkedUploadResponseDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'chunkSize',
    'uploadId',
  };
}

