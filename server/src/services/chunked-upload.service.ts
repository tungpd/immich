import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { createReadStream, createWriteStream } from 'node:fs';
import { mkdir, rm, stat } from 'node:fs/promises';
import { join } from 'node:path';
import { pipeline } from 'node:stream/promises';
import { StorageCore } from 'src/cores/storage.core';
import { AuthDto } from 'src/dtos/auth.dto';
import {
  ChunkedUploadStatusDto,
  FinalizeChunkedUploadDto,
  InitiateChunkedUploadDto,
  InitiateChunkedUploadResponseDto,
  UploadChunkDto,
  UploadChunkResponseDto,
} from 'src/dtos/chunked-upload.dto';
import { StorageFolder } from 'src/enum';
import { BaseService } from 'src/services/base.service';
import { UploadFile } from 'src/types';

const CHUNK_TEMP_FOLDER = 'chunked-uploads';

@Injectable()
export class ChunkedUploadService extends BaseService {
  async initiateUpload(auth: AuthDto, dto: InitiateChunkedUploadDto): Promise<InitiateChunkedUploadResponseDto> {
    const MAX_CHUNK_SIZE = 99 * 1024 * 1024;
    if (dto.chunkSize > MAX_CHUNK_SIZE) {
      throw new BadRequestException(`Chunk size cannot exceed ${MAX_CHUNK_SIZE} bytes`);
    }

    const expectedTotalChunks = Math.ceil(dto.fileSize / dto.chunkSize);
    if (dto.totalChunks !== expectedTotalChunks) {
      throw new BadRequestException(
        `Total chunks mismatch: expected ${expectedTotalChunks} based on file size and chunk size, but got ${dto.totalChunks}`,
      );
    }

    const upload = await this.chunkedUploadRepository.create(auth.user.id, {
      filename: dto.filename,
      fileSize: dto.fileSize,
      chunkSize: dto.chunkSize,
      totalChunks: dto.totalChunks,
      checksum: dto.checksum ?? null,
    });

    const tempPath = this.getTempUploadPath(upload.id);
    await mkdir(tempPath, { recursive: true });

    return {
      uploadId: upload.id,
      chunkSize: upload.chunkSize,
    };
  }

  async uploadChunk(auth: AuthDto, dto: UploadChunkDto, file: UploadFile): Promise<UploadChunkResponseDto> {
    const upload = await this.chunkedUploadRepository.getById(dto.uploadId);

    if (!upload) {
      throw new NotFoundException('Upload session not found or expired');
    }

    if (upload.userId !== auth.user.id) {
      throw new BadRequestException('Upload session does not belong to this user');
    }

    if (upload.complete) {
      throw new BadRequestException('Upload session is already complete');
    }

    if (dto.chunkIndex < 0 || dto.chunkIndex >= upload.totalChunks) {
      throw new BadRequestException(
        `Invalid chunk index ${dto.chunkIndex}. Must be between 0 and ${upload.totalChunks - 1}`,
      );
    }

    if (upload.chunksReceived.includes(dto.chunkIndex)) {
      this.logger.warn(`Chunk ${dto.chunkIndex} already received for upload ${upload.id}`);
      return {
        uploadId: upload.id,
        chunkIndex: dto.chunkIndex,
        chunksReceived: upload.chunksReceived.length,
        totalChunks: upload.totalChunks,
        complete: upload.chunksReceived.length === upload.totalChunks,
      };
    }

    const isLastChunk = dto.chunkIndex === upload.totalChunks - 1;
    const expectedSize = isLastChunk ? upload.fileSize - dto.chunkIndex * upload.chunkSize : upload.chunkSize;

    if (dto.chunkSize !== expectedSize) {
      throw new BadRequestException(
        `Invalid chunk size for chunk ${dto.chunkIndex}: expected ${expectedSize}, got ${dto.chunkSize}`,
      );
    }

    const chunkPath = this.getChunkPath(upload.id, dto.chunkIndex);
    const fileStats = await stat(file.originalPath);

    if (fileStats.size !== dto.chunkSize) {
      throw new BadRequestException(
        `Uploaded file size (${fileStats.size}) does not match declared chunk size (${dto.chunkSize})`,
      );
    }

    await pipeline(createReadStream(file.originalPath), createWriteStream(chunkPath));
    await rm(file.originalPath, { force: true });

    const updatedUpload = await this.chunkedUploadRepository.addChunk(upload.id, dto.chunkIndex);

    return {
      uploadId: updatedUpload.id,
      chunkIndex: dto.chunkIndex,
      chunksReceived: updatedUpload.chunksReceived.length,
      totalChunks: updatedUpload.totalChunks,
      complete: updatedUpload.chunksReceived.length === updatedUpload.totalChunks,
    };
  }

  async finalizeUpload(auth: AuthDto, dto: FinalizeChunkedUploadDto) {
    const upload = await this.chunkedUploadRepository.getById(dto.uploadId);

    if (!upload) {
      throw new NotFoundException('Upload session not found or expired');
    }

    if (upload.userId !== auth.user.id) {
      throw new BadRequestException('Upload session does not belong to this user');
    }

    if (upload.chunksReceived.length !== upload.totalChunks) {
      throw new BadRequestException(`Not all chunks received: ${upload.chunksReceived.length}/${upload.totalChunks}`);
    }

    const sortedChunks = [...upload.chunksReceived].sort((a, b) => a - b);
    for (let i = 0; i < sortedChunks.length; i++) {
      if (sortedChunks[i] !== i) {
        throw new BadRequestException(`Missing chunk ${i}`);
      }
    }

    const finalPath = await this.mergeChunks(upload);
    await this.chunkedUploadRepository.markComplete(upload.id, finalPath);

    const tempPath = this.getTempUploadPath(upload.id);
    await rm(tempPath, { recursive: true, force: true });

    return { uploadPath: finalPath };
  }

  async getUploadStatus(auth: AuthDto, uploadId: string): Promise<ChunkedUploadStatusDto> {
    const upload = await this.chunkedUploadRepository.getById(uploadId);

    if (!upload) {
      throw new NotFoundException('Upload session not found or expired');
    }

    if (upload.userId !== auth.user.id) {
      throw new BadRequestException('Upload session does not belong to this user');
    }

    return {
      uploadId: upload.id,
      filename: upload.filename,
      fileSize: Number(upload.fileSize),
      chunkSize: upload.chunkSize,
      totalChunks: upload.totalChunks,
      chunksReceived: upload.chunksReceived,
      complete: upload.complete,
      createdAt: new Date(upload.createdAt),
      updatedAt: new Date(upload.updatedAt),
    };
  }

  async cancelUpload(auth: AuthDto, uploadId: string): Promise<void> {
    const upload = await this.chunkedUploadRepository.getById(uploadId);

    if (!upload) {
      throw new NotFoundException('Upload session not found or expired');
    }

    if (upload.userId !== auth.user.id) {
      throw new BadRequestException('Upload session does not belong to this user');
    }

    await this.chunkedUploadRepository.delete(uploadId);

    const tempPath = this.getTempUploadPath(uploadId);
    await rm(tempPath, { recursive: true, force: true }).catch((error) => {
      this.logger.error(`Failed to delete temp directory for upload ${uploadId}:`, error);
    });
  }

  private getTempUploadPath(uploadId: string): string {
    return StorageCore.getBaseFolder(StorageFolder.Upload) + '/' + CHUNK_TEMP_FOLDER + '/' + uploadId;
  }

  private getChunkPath(uploadId: string, chunkIndex: number): string {
    return join(this.getTempUploadPath(uploadId), `chunk-${chunkIndex}`);
  }

  private async mergeChunks(upload: any): Promise<string> {
    const tempPath = this.getTempUploadPath(upload.id);
    const finalDir = StorageCore.getFolderLocation(StorageFolder.Upload, upload.userId);
    await mkdir(finalDir, { recursive: true });

    const finalPath = join(finalDir, upload.filename);
    const writeStream = createWriteStream(finalPath);

    try {
      for (let i = 0; i < upload.totalChunks; i++) {
        const chunkPath = this.getChunkPath(upload.id, i);
        const readStream = createReadStream(chunkPath);
        await pipeline(readStream, writeStream, { end: false });
      }
      writeStream.end();
    } catch (error) {
      await rm(finalPath, { force: true });
      throw error;
    }

    return finalPath;
  }

  async cleanupExpiredUploads(): Promise<void> {
    const expiredUploads = await this.chunkedUploadRepository.cleanup();

    for (const upload of expiredUploads) {
      const tempPath = this.getTempUploadPath(upload.id);
      await rm(tempPath, { recursive: true, force: true }).catch((error) => {
        this.logger.error(`Failed to cleanup temp directory for upload ${upload.id}:`, error);
      });
    }

    if (expiredUploads.length > 0) {
      this.logger.log(`Cleaned up ${expiredUploads.length} expired chunked uploads`);
    }
  }
}
