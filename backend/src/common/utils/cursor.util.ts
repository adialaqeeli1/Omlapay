/** Cursor format: base64(id:timestamp) */
const CURSOR_SEPARATOR = ':';

/**
 * Encode cursor for cursor-based pagination.
 * @param id - Entity ID
 * @param createdAt - Entity creation date
 */
export function encodeCursor(id: string, createdAt: Date): string {
  return Buffer.from(
    `${id}${CURSOR_SEPARATOR}${createdAt.getTime()}`,
    'utf8',
  ).toString('base64');
}

/**
 * Decode cursor for cursor-based pagination.
 * Supports both id:timestamp and legacy JSON {id, timestamp} formats.
 * @returns { id, timestamp } or null if invalid
 */
export function decodeCursor(
  cursor: string,
): { id: string; timestamp: Date } | null {
  try {
    const decoded = Buffer.from(cursor, 'base64').toString('utf8');
    const [id, ts] = decoded.split(CURSOR_SEPARATOR);
    if (id && ts) {
      const timestamp = new Date(parseInt(ts, 10));
      if (!isNaN(timestamp.getTime())) return { id, timestamp };
    }
    const parsed = JSON.parse(decoded) as { id?: string; timestamp?: string };
    if (parsed?.id && parsed?.timestamp) {
      const timestamp = new Date(parsed.timestamp);
      if (!isNaN(timestamp.getTime())) return { id: parsed.id, timestamp };
    }
    return null;
  } catch {
    return null;
  }
}
