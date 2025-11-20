import { Injectable } from '@nestjs/common';
import { Insertable, Kysely, Updateable } from 'kysely';
import { DateTime } from 'luxon';
import { InjectKysely } from 'nestjs-kysely';
import { DummyValue, GenerateSql } from 'src/decorators';
import { DB } from 'src/schema';
import { ChunkedUploadTable } from 'src/schema/tables/chunked-upload.table';

@Injectable()
export class ChunkedUploadRepository {
  constructor(@InjectKysely() private db: Kysely<DB>) {}

  @GenerateSql({ params: [DummyValue.UUID, DummyValue.STRING] })
  create(
    userId: string,
    upload: Omit<Insertable<ChunkedUploadTable>, 'userId' | 'chunksReceived' | 'complete' | 'expiresAt'>,
  ) {
    return this.db
      .insertInto('chunked_upload')
      .values({
        ...upload,
        userId,
        chunksReceived: [],
        complete: false,
        expiresAt: DateTime.now().plus({ hours: 24 }).toJSDate(),
      })
      .returningAll()
      .executeTakeFirstOrThrow();
  }

  @GenerateSql({ params: [DummyValue.UUID] })
  getById(id: string) {
    return this.db
      .selectFrom('chunked_upload')
      .selectAll()
      .where('id', '=', id)
      .where('complete', '=', false)
      .where((eb) => eb.or([eb('expiresAt', 'is', null), eb('expiresAt', '>', DateTime.now().toJSDate())]))
      .executeTakeFirst();
  }

  @GenerateSql({ params: [DummyValue.UUID, DummyValue.NUMBER] })
  addChunk(id: string, chunkIndex: number) {
    return this.db
      .updateTable('chunked_upload')
      .set((eb) => ({
        chunksReceived: eb.fn('array_append', ['chunksReceived', eb.lit(chunkIndex)]),
        updatedAt: DateTime.now().toJSDate(),
      }))
      .where('id', '=', id)
      .returningAll()
      .executeTakeFirstOrThrow();
  }

  @GenerateSql({ params: [DummyValue.UUID, { uploadPath: DummyValue.STRING }] })
  update(id: string, update: Updateable<ChunkedUploadTable>) {
    return this.db
      .updateTable('chunked_upload')
      .set({
        ...update,
        updatedAt: DateTime.now().toJSDate(),
      })
      .where('id', '=', id)
      .returningAll()
      .executeTakeFirstOrThrow();
  }

  @GenerateSql({ params: [DummyValue.UUID] })
  markComplete(id: string, uploadPath: string) {
    return this.db
      .updateTable('chunked_upload')
      .set({
        complete: true,
        uploadPath,
        updatedAt: DateTime.now().toJSDate(),
      })
      .where('id', '=', id)
      .returningAll()
      .executeTakeFirstOrThrow();
  }

  @GenerateSql({ params: [DummyValue.UUID] })
  delete(id: string) {
    return this.db.deleteFrom('chunked_upload').where('id', '=', id).execute();
  }

  cleanup() {
    return this.db
      .deleteFrom('chunked_upload')
      .where((eb) => eb.and([eb('expiresAt', 'is not', null), eb('expiresAt', '<=', DateTime.now().toJSDate())]))
      .returning(['id', 'userId', 'filename'])
      .execute();
  }

  @GenerateSql({ params: [DummyValue.UUID] })
  getByUserId(userId: string) {
    return this.db
      .selectFrom('chunked_upload')
      .selectAll()
      .where('userId', '=', userId)
      .where('complete', '=', false)
      .where((eb) => eb.or([eb('expiresAt', 'is', null), eb('expiresAt', '>', DateTime.now().toJSDate())]))
      .orderBy('createdAt', 'desc')
      .execute();
  }
}
