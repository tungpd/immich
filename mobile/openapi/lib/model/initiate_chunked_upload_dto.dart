//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InitiateChunkedUploadDto {
  /// Returns a new [InitiateChunkedUploadDto] instance.
  InitiateChunkedUploadDto({
    this.checksum,
    required this.chunkSize,
    required this.fileSize,
    required this.filename,
    required this.totalChunks,
  });

  /// SHA1 checksum of the complete file
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? checksum;

  /// Size of each chunk in bytes (except possibly the last one)
  ///
  /// Minimum value: 1
  num chunkSize;

  /// Total file size in bytes
  ///
  /// Minimum value: 1
  num fileSize;

  /// Original filename
  String filename;

  /// Total number of chunks
  ///
  /// Minimum value: 1
  num totalChunks;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InitiateChunkedUploadDto &&
    other.checksum == checksum &&
    other.chunkSize == chunkSize &&
    other.fileSize == fileSize &&
    other.filename == filename &&
    other.totalChunks == totalChunks;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (checksum == null ? 0 : checksum!.hashCode) +
    (chunkSize.hashCode) +
    (fileSize.hashCode) +
    (filename.hashCode) +
    (totalChunks.hashCode);

  @override
  String toString() => 'InitiateChunkedUploadDto[checksum=$checksum, chunkSize=$chunkSize, fileSize=$fileSize, filename=$filename, totalChunks=$totalChunks]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.checksum != null) {
      json[r'checksum'] = this.checksum;
    } else {
    //  json[r'checksum'] = null;
    }
      json[r'chunkSize'] = this.chunkSize;
      json[r'fileSize'] = this.fileSize;
      json[r'filename'] = this.filename;
      json[r'totalChunks'] = this.totalChunks;
    return json;
  }

  /// Returns a new [InitiateChunkedUploadDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InitiateChunkedUploadDto? fromJson(dynamic value) {
    upgradeDto(value, "InitiateChunkedUploadDto");
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return InitiateChunkedUploadDto(
        checksum: mapValueOfType<String>(json, r'checksum'),
        chunkSize: num.parse('${json[r'chunkSize']}'),
        fileSize: num.parse('${json[r'fileSize']}'),
        filename: mapValueOfType<String>(json, r'filename')!,
        totalChunks: num.parse('${json[r'totalChunks']}'),
      );
    }
    return null;
  }

  static List<InitiateChunkedUploadDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InitiateChunkedUploadDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InitiateChunkedUploadDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InitiateChunkedUploadDto> mapFromJson(dynamic json) {
    final map = <String, InitiateChunkedUploadDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InitiateChunkedUploadDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InitiateChunkedUploadDto-objects as value to a dart map
  static Map<String, List<InitiateChunkedUploadDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InitiateChunkedUploadDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InitiateChunkedUploadDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'chunkSize',
    'fileSize',
    'filename',
    'totalChunks',
  };
}

