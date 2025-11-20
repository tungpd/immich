//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FinalizeChunkedUploadDto {
  /// Returns a new [FinalizeChunkedUploadDto] instance.
  FinalizeChunkedUploadDto({
    required this.deviceAssetId,
    required this.deviceId,
    this.duration,
    required this.fileCreatedAt,
    required this.fileModifiedAt,
    this.filename,
    this.isFavorite,
    required this.uploadId,
  });

  /// Device asset ID
  String deviceAssetId;

  /// Device ID
  String deviceId;

  /// Duration for videos
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? duration;

  /// File created at timestamp (ISO 8601)
  String fileCreatedAt;

  /// File modified at timestamp (ISO 8601)
  String fileModifiedAt;

  /// Override filename
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? filename;

  /// Is favorite
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isFavorite;

  /// Upload session ID
  String uploadId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FinalizeChunkedUploadDto &&
    other.deviceAssetId == deviceAssetId &&
    other.deviceId == deviceId &&
    other.duration == duration &&
    other.fileCreatedAt == fileCreatedAt &&
    other.fileModifiedAt == fileModifiedAt &&
    other.filename == filename &&
    other.isFavorite == isFavorite &&
    other.uploadId == uploadId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceAssetId.hashCode) +
    (deviceId.hashCode) +
    (duration == null ? 0 : duration!.hashCode) +
    (fileCreatedAt.hashCode) +
    (fileModifiedAt.hashCode) +
    (filename == null ? 0 : filename!.hashCode) +
    (isFavorite == null ? 0 : isFavorite!.hashCode) +
    (uploadId.hashCode);

  @override
  String toString() => 'FinalizeChunkedUploadDto[deviceAssetId=$deviceAssetId, deviceId=$deviceId, duration=$duration, fileCreatedAt=$fileCreatedAt, fileModifiedAt=$fileModifiedAt, filename=$filename, isFavorite=$isFavorite, uploadId=$uploadId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deviceAssetId'] = this.deviceAssetId;
      json[r'deviceId'] = this.deviceId;
    if (this.duration != null) {
      json[r'duration'] = this.duration;
    } else {
    //  json[r'duration'] = null;
    }
      json[r'fileCreatedAt'] = this.fileCreatedAt;
      json[r'fileModifiedAt'] = this.fileModifiedAt;
    if (this.filename != null) {
      json[r'filename'] = this.filename;
    } else {
    //  json[r'filename'] = null;
    }
    if (this.isFavorite != null) {
      json[r'isFavorite'] = this.isFavorite;
    } else {
    //  json[r'isFavorite'] = null;
    }
      json[r'uploadId'] = this.uploadId;
    return json;
  }

  /// Returns a new [FinalizeChunkedUploadDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FinalizeChunkedUploadDto? fromJson(dynamic value) {
    upgradeDto(value, "FinalizeChunkedUploadDto");
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return FinalizeChunkedUploadDto(
        deviceAssetId: mapValueOfType<String>(json, r'deviceAssetId')!,
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        duration: mapValueOfType<String>(json, r'duration'),
        fileCreatedAt: mapValueOfType<String>(json, r'fileCreatedAt')!,
        fileModifiedAt: mapValueOfType<String>(json, r'fileModifiedAt')!,
        filename: mapValueOfType<String>(json, r'filename'),
        isFavorite: mapValueOfType<bool>(json, r'isFavorite'),
        uploadId: mapValueOfType<String>(json, r'uploadId')!,
      );
    }
    return null;
  }

  static List<FinalizeChunkedUploadDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FinalizeChunkedUploadDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FinalizeChunkedUploadDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FinalizeChunkedUploadDto> mapFromJson(dynamic json) {
    final map = <String, FinalizeChunkedUploadDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FinalizeChunkedUploadDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FinalizeChunkedUploadDto-objects as value to a dart map
  static Map<String, List<FinalizeChunkedUploadDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FinalizeChunkedUploadDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FinalizeChunkedUploadDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceAssetId',
    'deviceId',
    'fileCreatedAt',
    'fileModifiedAt',
    'uploadId',
  };
}

