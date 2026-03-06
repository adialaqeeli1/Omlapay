/**
 * Minimal Multer file interface.
 * Matches Express.Multer.File from @types/multer.
 * Used to avoid dependency on @types/multer.
 */
export interface MulterFile {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  size: number;
  destination?: string;
  filename?: string;
  path?: string;
  buffer?: Buffer;
  stream?: NodeJS.ReadableStream;
}
