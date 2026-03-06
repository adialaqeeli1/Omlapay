/**
 * Result of a successful file upload.
 * Same structure regardless of storage backend (local, S3, etc.).
 */
export interface UploadResult {
  /** Public URL to access the file */
  url: string;
  /** Storage key/path (for deletion or S3 key) */
  key: string;
  /** Original filename */
  filename: string;
  /** MIME type */
  mimetype: string;
  /** File size in bytes */
  size: number;
}

/**
 * Options for upload operations.
 */
export interface UploadOptions {
  /** User ID for scoping uploads (e.g. support-requests/{userId}/) */
  userId?: string;
  /** Path prefix (e.g. 'support-requests', 'profiles') */
  prefix?: string;
}

import type { MulterFile } from './multer-file.interface';

/**
 * Storage service abstraction.
 * Implemented by S3StorageService (AWS S3).
 */
export interface IStorageService {
  /**
   * Upload a single file.
   * @param file - Multer file object
   * @param options - Optional userId and prefix for path scoping
   * @returns Upload result with public URL
   */
  upload(file: MulterFile, options?: UploadOptions): Promise<UploadResult>;

  /**
   * Upload multiple files.
   * @param files - Array of Multer file objects
   * @param options - Optional userId and prefix for path scoping
   * @returns Array of upload results
   */
  uploadMultiple(
    files: MulterFile[],
    options?: UploadOptions,
  ): Promise<UploadResult[]>;
}
