import { Kysely, sql } from 'kysely';

export async function up(db: Kysely<any>): Promise<void> {
  await sql`CREATE TABLE "chunked_upload" (
  "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
  "filename" character varying NOT NULL,
  "fileSize" bigint NOT NULL,
  "chunkSize" integer NOT NULL,
  "totalChunks" integer NOT NULL,
  "chunksReceived" integer[] NOT NULL DEFAULT '{}'::integer[],
  "checksum" character varying,
  "complete" boolean NOT NULL DEFAULT false,
  "uploadPath" character varying,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now(),
  "expiresAt" timestamp with time zone,
  "userId" uuid NOT NULL,
  CONSTRAINT "chunked_upload_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT "chunked_upload_pkey" PRIMARY KEY ("id")
);`.execute(db);

  await sql`CREATE INDEX "chunked_upload_userId_idx" ON "chunked_upload" ("userId");`.execute(db);
  await sql`CREATE INDEX "chunked_upload_complete_idx" ON "chunked_upload" ("complete");`.execute(db);
  await sql`CREATE INDEX "chunked_upload_expiresAt_idx" ON "chunked_upload" ("expiresAt");`.execute(db);
}

export async function down(db: Kysely<any>): Promise<void> {
  await sql`DROP TABLE IF EXISTS "chunked_upload";`.execute(db);
}
