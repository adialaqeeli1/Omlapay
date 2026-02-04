import { HttpStatus } from '@nestjs/common';
import { createHash } from 'crypto';
import path from 'path';

export const SendResponse = (
  message: string,
  data: unknown = undefined,
  statusCode: number = HttpStatus.OK,
) => ({ statusCode, message, data });

export function generateRandomString(length = 20) {
  const characters =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  const charactersLength = characters.length;
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

export function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

export const generateHash = (value: string = generateRandomString()) => {
  return createHash('sha256').update(value).digest('hex');
};

export const getRootDir = () => {
  return path.resolve(__dirname, '../..'); // Adjust according to your directory structure
};
