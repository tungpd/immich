import { UpdatedAtTrigger } from 'src/decorators';
import { UserTable } from 'src/schema/tables/user.table';
import {
  Column,
  CreateDateColumn,
  ForeignKeyColumn,
  Generated,
  PrimaryGeneratedColumn,
  Table,
  Timestamp,
  UpdateDateColumn,
} from 'src/sql-tools';

@Table('chunked_upload')
@UpdatedAtTrigger('chunked_upload_updatedAt')
export class ChunkedUploadTable {
  @PrimaryGeneratedColumn()
  id!: Generated<string>;

  @Column()
  filename!: string;

  @Column({ type: 'bigint' })
  fileSize!: number;

  @Column({ type: 'integer' })
  chunkSize!: number;

  @Column({ type: 'integer' })
  totalChunks!: number;

  @Column({ type: 'integer', array: true, default: [] })
  chunksReceived!: Generated<number[]>;

  @Column({ nullable: true })
  checksum!: string | null;

  @Column({ default: false })
  complete!: Generated<boolean>;

  @Column({ nullable: true })
  uploadPath!: string | null;

  @CreateDateColumn()
  createdAt!: Generated<Timestamp>;

  @UpdateDateColumn()
  updatedAt!: Generated<Timestamp>;

  @Column({ type: 'timestamp with time zone', nullable: true })
  expiresAt!: Timestamp | null;

  @ForeignKeyColumn(() => UserTable, { onUpdate: 'CASCADE', onDelete: 'CASCADE' })
  userId!: string;
}
