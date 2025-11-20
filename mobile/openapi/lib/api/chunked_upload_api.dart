//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ChunkedUploadApi {
  ChunkedUploadApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'DELETE /chunked-upload/{uploadId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] uploadId (required):
  Future<Response> cancelUploadWithHttpInfo(String uploadId,) async {
    // ignore: prefer_const_declarations
    final apiPath = r'/chunked-upload/{uploadId}'
      .replaceAll('{uploadId}', uploadId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      apiPath,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] uploadId (required):
  Future<void> cancelUpload(String uploadId,) async {
    final response = await cancelUploadWithHttpInfo(uploadId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /chunked-upload/{uploadId}/finalize' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] uploadId (required):
  ///
  /// * [FinalizeChunkedUploadDto] finalizeChunkedUploadDto (required):
  Future<Response> finalizeUploadWithHttpInfo(String uploadId, FinalizeChunkedUploadDto finalizeChunkedUploadDto,) async {
    // ignore: prefer_const_declarations
    final apiPath = r'/chunked-upload/{uploadId}/finalize'
      .replaceAll('{uploadId}', uploadId);

    // ignore: prefer_final_locals
    Object? postBody = finalizeChunkedUploadDto;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      apiPath,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] uploadId (required):
  ///
  /// * [FinalizeChunkedUploadDto] finalizeChunkedUploadDto (required):
  Future<void> finalizeUpload(String uploadId, FinalizeChunkedUploadDto finalizeChunkedUploadDto,) async {
    final response = await finalizeUploadWithHttpInfo(uploadId, finalizeChunkedUploadDto,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /chunked-upload/{uploadId}/status' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] uploadId (required):
  Future<Response> getUploadStatusWithHttpInfo(String uploadId,) async {
    // ignore: prefer_const_declarations
    final apiPath = r'/chunked-upload/{uploadId}/status'
      .replaceAll('{uploadId}', uploadId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      apiPath,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] uploadId (required):
  Future<ChunkedUploadStatusDto?> getUploadStatus(String uploadId,) async {
    final response = await getUploadStatusWithHttpInfo(uploadId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChunkedUploadStatusDto',) as ChunkedUploadStatusDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /chunked-upload/initiate' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [InitiateChunkedUploadDto] initiateChunkedUploadDto (required):
  Future<Response> initiateUploadWithHttpInfo(InitiateChunkedUploadDto initiateChunkedUploadDto,) async {
    // ignore: prefer_const_declarations
    final apiPath = r'/chunked-upload/initiate';

    // ignore: prefer_final_locals
    Object? postBody = initiateChunkedUploadDto;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      apiPath,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [InitiateChunkedUploadDto] initiateChunkedUploadDto (required):
  Future<InitiateChunkedUploadResponseDto?> initiateUpload(InitiateChunkedUploadDto initiateChunkedUploadDto,) async {
    final response = await initiateUploadWithHttpInfo(initiateChunkedUploadDto,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'InitiateChunkedUploadResponseDto',) as InitiateChunkedUploadResponseDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /chunked-upload/{uploadId}/chunk' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] uploadId (required):
  ///
  /// * [num] chunkIndex (required):
  ///
  /// * [num] chunkSize (required):
  ///
  /// * [MultipartFile] file (required):
  Future<Response> uploadChunkWithHttpInfo(String uploadId, num chunkIndex, num chunkSize, MultipartFile file,) async {
    // ignore: prefer_const_declarations
    final apiPath = r'/chunked-upload/{uploadId}/chunk'
      .replaceAll('{uploadId}', uploadId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['multipart/form-data'];

    bool hasFields = false;
    final mp = MultipartRequest('POST', Uri.parse(apiPath));
    if (chunkIndex != null) {
      hasFields = true;
      mp.fields[r'chunkIndex'] = parameterToString(chunkIndex);
    }
    if (chunkSize != null) {
      hasFields = true;
      mp.fields[r'chunkSize'] = parameterToString(chunkSize);
    }
    if (file != null) {
      hasFields = true;
      mp.fields[r'file'] = file.field;
      mp.files.add(file);
    }
    if (hasFields) {
      postBody = mp;
    }

    return apiClient.invokeAPI(
      apiPath,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] uploadId (required):
  ///
  /// * [num] chunkIndex (required):
  ///
  /// * [num] chunkSize (required):
  ///
  /// * [MultipartFile] file (required):
  Future<UploadChunkResponseDto?> uploadChunk(String uploadId, num chunkIndex, num chunkSize, MultipartFile file,) async {
    final response = await uploadChunkWithHttpInfo(uploadId, chunkIndex, chunkSize, file,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UploadChunkResponseDto',) as UploadChunkResponseDto;
    
    }
    return null;
  }
}
