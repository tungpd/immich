import 'dart:io';
import 'dart:typed_data';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/providers/api.provider.dart';
import 'package:immich_mobile/services/api.service.dart';
import 'package:logging/logging.dart';
import 'package:openapi/api.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:path/path.dart' as p;

final chunkedUploadServiceProvider = Provider((ref) {
  return ChunkedUploadService(ref.watch(apiServiceProvider));
});

/// Service for handling chunked file uploads for files larger than 99MB
class ChunkedUploadService {
  ChunkedUploadService(this._apiService);

  final ApiService _apiService;
  final Logger _logger = Logger('ChunkedUploadService');

  static const int maxChunkSize = 99 * 1024 * 1024;

  static Future<bool> shouldUseChunkedUpload(File file) async {
    final fileSize = await file.length();
    return fileSize >= maxChunkSize;
  }

  Future<String> uploadFileChunked(
    File file, {
    required String deviceAssetId,
    required String deviceId,
    required DateTime fileCreatedAt,
    required DateTime fileModifiedAt,
    String? duration,
    String? filename,
    bool isFavorite = false,
    void Function(double progress)? onProgress,
  }) async {
    final actualFilename = filename ?? p.basename(file.path);
    final fileSize = await file.length();
    final chunkSize = maxChunkSize;
    final totalChunks = (fileSize / chunkSize).ceil();

    _logger.info('Initiating chunked upload for $actualFilename');

    final initiateDto = InitiateChunkedUploadDto(
      filename: actualFilename,
      fileSize: fileSize,
      chunkSize: chunkSize,
      totalChunks: totalChunks,
    );

    final initiateResponse = await _apiService.chunkedUploadApi.initiateUpload(initiateDto);
    if (initiateResponse == null) {
      throw Exception('Failed to initiate chunked upload');
    }

    final uploadId = initiateResponse.uploadId;
    _logger.info('Upload session created: $uploadId');

    int chunkIndex = 0;
    int bytesUploaded = 0;

    try {
      final fileStream = file.openRead();
      await for (final chunk in _readChunks(fileStream, chunkSize)) {
        await _uploadChunk(uploadId: uploadId, chunkIndex: chunkIndex, chunkSize: chunk.length, chunkData: chunk);

        bytesUploaded += chunk.length;
        chunkIndex++;

        if (onProgress != null) {
          onProgress(bytesUploaded / fileSize);
        }
      }

      if (chunkIndex != totalChunks) {
        throw Exception('Chunk count mismatch');
      }

      final finalizeDto = FinalizeChunkedUploadDto(
        uploadId: uploadId,
        deviceAssetId: deviceAssetId,
        deviceId: deviceId,
        fileCreatedAt: fileCreatedAt.toIso8601String(),
        fileModifiedAt: fileModifiedAt.toIso8601String(),
        duration: duration,
        filename: actualFilename,
        isFavorite: isFavorite,
      );

      await _apiService.chunkedUploadApi.finalizeUpload(uploadId, finalizeDto);
      _logger.info('Chunked upload completed successfully');
      return uploadId;
    } catch (e) {
      _logger.severe('Error during chunked upload: $e');
      await _cancelUpload(uploadId);
      rethrow;
    }
  }

  Future<ChunkedUploadStatusDto?> getUploadStatus(String uploadId) async {
    return await _apiService.chunkedUploadApi.getUploadStatus(uploadId);
  }

  Future<void> cancelUpload(String uploadId) async {
    await _cancelUpload(uploadId);
  }

  Future<void> _uploadChunk({
    required String uploadId,
    required int chunkIndex,
    required int chunkSize,
    required Uint8List chunkData,
  }) async {
    final multipartFile = MultipartFile.fromBytes('file', chunkData, filename: 'chunk-$chunkIndex');

    await _apiService.chunkedUploadApi.uploadChunk(uploadId, chunkIndex, chunkSize, multipartFile);
  }

  Future<void> _cancelUpload(String uploadId) async {
    try {
      await _apiService.chunkedUploadApi.cancelUpload(uploadId);
      _logger.info('Chunked upload cancelled: $uploadId');
    } catch (e) {
      _logger.warning('Failed to cancel upload $uploadId: $e');
    }
  }

  Stream<Uint8List> _readChunks(Stream<List<int>> stream, int chunkSize) async* {
    final buffer = <int>[];
    await for (final data in stream) {
      buffer.addAll(data);
      while (buffer.length >= chunkSize) {
        yield Uint8List.fromList(buffer.sublist(0, chunkSize));
        buffer.removeRange(0, chunkSize);
      }
    }
    if (buffer.isNotEmpty) {
      yield Uint8List.fromList(buffer);
    }
  }
}
