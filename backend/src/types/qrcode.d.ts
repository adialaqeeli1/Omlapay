declare module 'qrcode' {
  export function toBuffer(
    text: string,
    options?: { width?: number; margin?: number; type?: string; errorCorrectionLevel?: string },
  ): Promise<Buffer>;

  export function toString(
    text: string,
    options?: { width?: number; margin?: number; type?: string; errorCorrectionLevel?: string },
  ): Promise<string>;

  export function toDataURL(
    text: string,
    options?: { width?: number; margin?: number; type?: string; errorCorrectionLevel?: string },
  ): Promise<string>;
}
