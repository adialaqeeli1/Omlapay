/* eslint-disable @typescript-eslint/no-unsafe-member-access --
   rows are untyped stand-ins for TypeORM entities */
import { randomUUID } from 'crypto';
import { FindOperator } from 'typeorm';

type Where<T> = Partial<Record<keyof T, unknown>>;

/** Compares numbers, dates and numeric strings (e.g. decimal balances) the way Postgres would */
const num = (v: unknown) =>
  v instanceof Date
    ? v.getTime()
    : typeof v === 'string'
      ? Number(v)
      : (v as number);

/**
 * Tiny in-memory stand-in for a TypeORM repository: findOne / find / count / save / update /
 * delete on equal fields, IsNull(), In(), MoreThan() and LessThanOrEqual(), and where-arrays (OR).
 */
export class FakeRepo<T extends { id?: string; createdAt?: Date }> {
  rows: T[] = [];
  private test(value: unknown, cond: unknown): boolean {
    if (!(cond instanceof FindOperator)) return value === cond;
    const arg: unknown = cond.value;
    switch (cond.type) {
      case 'isNull':
        return value == null;
      case 'in':
        return (arg as unknown[]).includes(value);
      case 'moreThan':
        return value != null && num(value) > num(arg);
      case 'lessThanOrEqual':
        return value != null && num(value) <= num(arg);
      default:
        throw new Error(`FakeRepo: unsupported operator ${cond.type}`);
    }
  }
  private matches(row: T, where: Where<T> | Where<T>[]): boolean {
    if (Array.isArray(where)) return where.some((w) => this.matches(row, w));
    return Object.entries(where).every(([k, v]) =>
      this.test((row as any)[k], v),
    );
  }
  findOne(opts: { where: Where<T> | Where<T>[] }) {
    const found = this.rows.filter((r) => this.matches(r, opts.where));
    return Promise.resolve(found.length ? found[found.length - 1] : null);
  }
  find(opts: { where: Where<T> | Where<T>[]; take?: number }) {
    const found = this.rows.filter((r) => this.matches(r, opts.where));
    return Promise.resolve(found.slice(0, opts.take ?? found.length));
  }
  count(opts: { where: Where<T> | Where<T>[] }) {
    return Promise.resolve(
      this.rows.filter((r) => this.matches(r, opts.where)).length,
    );
  }
  save(entity: Partial<T>) {
    if (!entity.id) {
      entity.id = randomUUID();
      entity.createdAt = new Date();
      this.rows.push(entity as T);
    }
    return Promise.resolve(entity as T);
  }
  update(where: Where<T>, patch: Partial<T>) {
    const hit = this.rows.filter((r) => this.matches(r, where));
    hit.forEach((r) => Object.assign(r, patch));
    return Promise.resolve({ affected: hit.length });
  }
  delete(where: Where<T>) {
    const before = this.rows.length;
    this.rows = this.rows.filter((r) => !this.matches(r, where));
    return Promise.resolve({ affected: before - this.rows.length });
  }
}
