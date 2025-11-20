import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBody, ApiConsumes, ApiTags } from '@nestjs/swagger';
import { UploadFieldName } from 'src/dtos/asset-media.dto';
import { AuthDto } from 'src/dtos/auth.dto';
import {
  ChunkedUploadStatusDto,
  FinalizeChunkedUploadDto,
  InitiateChunkedUploadDto,
  InitiateChunkedUploadResponseDto,
  UploadChunkResponseDto,
} from 'src/dtos/chunked-upload.dto';
import { Auth, Authenticated } from 'src/middleware/auth.guard';
import { ChunkedUploadService } from 'src/services/chunked-upload.service';
import { UploadFile } from 'src/types';

@ApiTags('Chunked Upload')
@Controller('chunked-upload')
export class ChunkedUploadController {
  constructor(private service: ChunkedUploadService) {}

  @Post('initiate')
  @Authenticated()
  @HttpCode(HttpStatus.CREATED)
  initiateUpload(
    @Auth() auth: AuthDto,
    @Body() dto: InitiateChunkedUploadDto,
  ): Promise<InitiateChunkedUploadResponseDto> {
    return this.service.initiateUpload(auth, dto);
  }

  @Post(':uploadId/chunk')
  @Authenticated()
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        chunkIndex: { type: 'number' },
        chunkSize: { type: 'number' },
        file: {
          type: 'string',
          format: 'binary',
        },
      },
      required: ['chunkIndex', 'chunkSize', 'file'],
    },
  })
  async uploadChunk(
    @Auth() auth: AuthDto,
    @Param('uploadId') uploadId: string,
    @Body('chunkIndex') chunkIndex: string,
    @Body('chunkSize') chunkSize: string,
    @UploadedFile() file: Express.Multer.File,
  ): Promise<UploadChunkResponseDto> {
    const dto = {
      uploadId,
      chunkIndex: Number.parseInt(chunkIndex, 10),
      chunkSize: Number.parseInt(chunkSize, 10),
      [UploadFieldName.ASSET_DATA]: file.buffer,
    };

    const uploadFile: UploadFile = {
      uuid: '', // Not used for chunked upload
      checksum: Buffer.alloc(0), // Not used for chunked upload
      originalPath: file.path || '',
      originalName: file.originalname,
      size: file.size,
    };

    return this.service.uploadChunk(auth, dto, uploadFile);
  }

  @Post(':uploadId/finalize')
  @Authenticated()
  @HttpCode(HttpStatus.OK)
  finalizeUpload(
    @Auth() auth: AuthDto,
    @Param('uploadId') uploadId: string,
    @Body() dto: FinalizeChunkedUploadDto,
  ): Promise<{ uploadPath: string }> {
    return this.service.finalizeUpload(auth, { ...dto, uploadId });
  }

  @Get(':uploadId/status')
  @Authenticated()
  getUploadStatus(@Auth() auth: AuthDto, @Param('uploadId') uploadId: string): Promise<ChunkedUploadStatusDto> {
    return this.service.getUploadStatus(auth, uploadId);
  }

  @Delete(':uploadId')
  @Authenticated()
  @HttpCode(HttpStatus.NO_CONTENT)
  async cancelUpload(@Auth() auth: AuthDto, @Param('uploadId') uploadId: string): Promise<void> {
    await this.service.cancelUpload(auth, uploadId);
  }
}
