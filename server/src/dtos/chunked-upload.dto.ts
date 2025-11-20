import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsNotEmpty, IsOptional, IsPositive, IsString, Min } from 'class-validator';
import { UploadFieldName } from 'src/dtos/asset-media.dto';

/**
 * DTO for initiating a chunked upload session
 */
export class InitiateChunkedUploadDto {
  @IsNotEmpty()
  @IsString()
  @ApiProperty({ description: 'Original filename' })
  filename!: string;

  @IsPositive()
  @IsInt()
  @ApiProperty({ description: 'Total file size in bytes' })
  fileSize!: number;

  @IsPositive()
  @IsInt()
  @ApiProperty({ description: 'Size of each chunk in bytes (except possibly the last one)' })
  chunkSize!: number;

  @IsPositive()
  @IsInt()
  @ApiProperty({ description: 'Total number of chunks' })
  totalChunks!: number;

  @IsOptional()
  @IsString()
  @ApiProperty({ description: 'SHA1 checksum of the complete file', required: false })
  checksum?: string;
}

/**
 * Response when initiating a chunked upload
 */
export class InitiateChunkedUploadResponseDto {
  @ApiProperty({ description: 'Unique upload session ID' })
  uploadId!: string;

  @ApiProperty({ description: 'Chunk size to use for uploads' })
  chunkSize!: number;
}

/**
 * DTO for uploading a single chunk
 */
export class UploadChunkDto {
  @IsNotEmpty()
  @IsString()
  @ApiProperty({ description: 'Upload session ID from initiate call' })
  uploadId!: string;

  @IsInt()
  @Min(0)
  @ApiProperty({ description: 'Zero-based chunk index' })
  chunkIndex!: number;

  @IsPositive()
  @IsInt()
  @ApiProperty({ description: 'Size of this chunk in bytes' })
  chunkSize!: number;

  @IsOptional()
  @IsString()
  @ApiProperty({ description: 'SHA1 checksum of this chunk', required: false })
  chunkChecksum?: string;

  // The chunk data itself
  @ApiProperty({ type: 'string', format: 'binary' })
  [UploadFieldName.ASSET_DATA]!: any;
}

/**
 * Response after uploading a chunk
 */
export class UploadChunkResponseDto {
  @ApiProperty({ description: 'Upload session ID' })
  uploadId!: string;

  @ApiProperty({ description: 'Chunk index that was uploaded' })
  chunkIndex!: number;

  @ApiProperty({ description: 'Total chunks received so far' })
  chunksReceived!: number;

  @ApiProperty({ description: 'Total chunks expected' })
  totalChunks!: number;

  @ApiProperty({ description: 'Whether all chunks have been received' })
  complete!: boolean;
}

/**
 * DTO for finalizing a chunked upload and creating the asset
 */
export class FinalizeChunkedUploadDto {
  @IsNotEmpty()
  @IsString()
  @ApiProperty({ description: 'Upload session ID' })
  uploadId!: string;

  @IsNotEmpty()
  @IsString()
  @ApiProperty({ description: 'Device asset ID' })
  deviceAssetId!: string;

  @IsNotEmpty()
  @IsString()
  @ApiProperty({ description: 'Device ID' })
  deviceId!: string;

  @IsNotEmpty()
  @IsString()
  @ApiProperty({ description: 'File created at timestamp (ISO 8601)' })
  fileCreatedAt!: string;

  @IsNotEmpty()
  @IsString()
  @ApiProperty({ description: 'File modified at timestamp (ISO 8601)' })
  fileModifiedAt!: string;

  @IsOptional()
  @IsString()
  @ApiProperty({ description: 'Duration for videos', required: false })
  duration?: string;

  @IsOptional()
  @IsString()
  @ApiProperty({ description: 'Override filename', required: false })
  filename?: string;

  @IsOptional()
  @ApiProperty({ description: 'Is favorite', required: false })
  isFavorite?: boolean;
}

/**
 * DTO for resuming an incomplete upload
 */
export class ResumeChunkedUploadDto {
  @IsNotEmpty()
  @IsString()
  @ApiProperty({ description: 'Upload session ID to resume' })
  uploadId!: string;
}

/**
 * Response with the state of an upload session
 */
export class ChunkedUploadStatusDto {
  @ApiProperty({ description: 'Upload session ID' })
  uploadId!: string;

  @ApiProperty({ description: 'Original filename' })
  filename!: string;

  @ApiProperty({ description: 'Total file size' })
  fileSize!: number;

  @ApiProperty({ description: 'Chunk size' })
  chunkSize!: number;

  @ApiProperty({ description: 'Total chunks' })
  totalChunks!: number;

  @ApiProperty({ description: 'Chunks received so far', type: [Number] })
  chunksReceived!: number[];

  @ApiProperty({ description: 'Whether upload is complete' })
  complete!: boolean;

  @ApiProperty({ description: 'Upload created timestamp' })
  createdAt!: Date;

  @ApiProperty({ description: 'Last updated timestamp' })
  updatedAt!: Date;
}
