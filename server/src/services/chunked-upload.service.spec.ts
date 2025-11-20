import { BadRequestException, NotFoundException } from '@nestjs/common';
import { ChunkedUploadService } from 'src/services/chunked-upload.service';
import { authStub } from 'test/fixtures/auth.stub';
import { newTestService } from 'test/utils';
import { describe, expect, it } from 'vitest';

describe(ChunkedUploadService.name, () => {
  let sut: ChunkedUploadService;
  let mocks: ReturnType<typeof newTestService>['mocks'];

  beforeEach(() => {
    const result = newTestService(ChunkedUploadService);
    sut = result.sut;
    mocks = result.mocks;
  });

  it('should be defined', () => {
    expect(sut).toBeDefined();
  });

  describe('initiateUpload', () => {
    it('should reject chunk size over 99MB', async () => {
      const dto = {
        filename: 'large-video.mp4',
        fileSize: 200_000_000,
        chunkSize: 100 * 1024 * 1024, // 100MB - too large
        totalChunks: 2,
      };

      await expect(sut.initiateUpload(authStub.user1, dto)).rejects.toThrow(BadRequestException);
    });

    it('should reject mismatched totalChunks', async () => {
      const dto = {
        filename: 'large-video.mp4',
        fileSize: 200_000_000,
        chunkSize: 99 * 1024 * 1024,
        totalChunks: 5, // Wrong - should be 2
      };

      await expect(sut.initiateUpload(authStub.user1, dto)).rejects.toThrow(BadRequestException);
    });
  });

  describe('getUploadStatus', () => {
    it('should return upload status', async () => {
      const uploadId = 'upload-123';
      const mockUpload = {
        id: uploadId,
        userId: authStub.user1.user.id,
        filename: 'test.mp4',
        fileSize: 200_000_000, // Changed from BigInt to number
        chunkSize: 99 * 1024 * 1024,
        totalChunks: 3,
        chunksReceived: [0, 1],
        checksum: null,
        complete: false,
        uploadPath: null,
        createdAt: new Date('2024-01-01'),
        updatedAt: new Date('2024-01-01'),
        expiresAt: null,
      };

      mocks.chunkedUpload.getById.mockResolvedValue(mockUpload);

      const result = await sut.getUploadStatus(authStub.user1, uploadId);

      expect(result).toEqual({
        uploadId: uploadId,
        filename: 'test.mp4',
        fileSize: 200_000_000,
        chunkSize: 99 * 1024 * 1024,
        totalChunks: 3,
        chunksReceived: [0, 1],
        complete: false,
        createdAt: new Date('2024-01-01'),
        updatedAt: new Date('2024-01-01'),
      });
    });

    it('should throw NotFoundException if upload does not exist', async () => {
      mocks.chunkedUpload.getById.mockResolvedValue(undefined);

      await expect(sut.getUploadStatus(authStub.user1, 'nonexistent')).rejects.toThrow(NotFoundException);
    });

    it('should throw BadRequestException if upload belongs to different user', async () => {
      const mockUpload = {
        id: 'upload-123',
        userId: 'different-user-id',
        filename: 'test.mp4',
        fileSize: 200_000_000,
        chunkSize: 99 * 1024 * 1024,
        totalChunks: 3,
        chunksReceived: [],
        checksum: null,
        complete: false,
        uploadPath: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        expiresAt: null,
      };

      mocks.chunkedUpload.getById.mockResolvedValue(mockUpload);

      await expect(sut.getUploadStatus(authStub.user1, 'upload-123')).rejects.toThrow(BadRequestException);
    });
  });

  describe('cancelUpload', () => {
    it('should delete upload session', async () => {
      const uploadId = 'upload-123';
      const mockUpload = {
        id: uploadId,
        userId: authStub.user1.user.id,
        filename: 'test.mp4',
        fileSize: 200_000_000,
        chunkSize: 99 * 1024 * 1024,
        totalChunks: 3,
        chunksReceived: [],
        checksum: null,
        complete: false,
        uploadPath: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        expiresAt: null,
      };

      mocks.chunkedUpload.getById.mockResolvedValue(mockUpload);
      mocks.chunkedUpload.delete.mockResolvedValue([]);

      await sut.cancelUpload(authStub.user1, uploadId);

      expect(mocks.chunkedUpload.delete).toHaveBeenCalledWith(uploadId);
    });

    it('should throw NotFoundException if upload does not exist', async () => {
      mocks.chunkedUpload.getById.mockResolvedValue(undefined);

      await expect(sut.cancelUpload(authStub.user1, 'nonexistent')).rejects.toThrow(NotFoundException);
    });

    it('should throw BadRequestException if upload belongs to different user', async () => {
      const mockUpload = {
        id: 'upload-123',
        userId: 'different-user-id',
        filename: 'test.mp4',
        fileSize: 200_000_000,
        chunkSize: 99 * 1024 * 1024,
        totalChunks: 3,
        chunksReceived: [],
        checksum: null,
        complete: false,
        uploadPath: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        expiresAt: null,
      };

      mocks.chunkedUpload.getById.mockResolvedValue(mockUpload);

      await expect(sut.cancelUpload(authStub.user1, 'upload-123')).rejects.toThrow(BadRequestException);
    });
  });
});
