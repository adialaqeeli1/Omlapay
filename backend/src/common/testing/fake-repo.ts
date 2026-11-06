/* eslint-disable @typescript-eslint/no-unsafe-member-access --
   rows are untyped stand-ins for TypeORM entities */
import { FindOperator } from 'typeorm';

/** Tiny in-memory stand-in for a TypeORM repository (findOne / save / update / delete on equal fields, IsNull()). */
export class FakeRepo<T extends { id?: string; createdAt?: Date }> {
  rows: T[] = [];
  private seq = 0;
  private matches(row: T, where: Partial<T>) {
    return Object.entries(where).every(([k, v]) =>
      v instanceof FindOperator && v.type === 'isNull'
        ? (row as any)[k] == null
        : (row as any)[k] === v,
    );
  }
  findOne(opts: { where: Partial<T> }) {
    const found = this.rows.filter((r) => this.matches(r, opts.where));
    return Promise.resolve(found.length ? found[found.length - 1] : null);
  }
  save(entity: Partial<T>) {
    if (!entity.id) {
      entity.id = `id-${++this.seq}`;
      entity.createdAt = new Date();
      this.rows.push(entity as T);
    }
    return Promise.resolve(entity as T);
  }
  update(where: Partial<T>, patch: Partial<T>) {
    const hit = this.rows.filter((r) => this.matches(r, where));
    hit.forEach((r) => Object.assign(r, patch));
    return Promise.resolve({ affected: hit.length });
  }
  delete(where: Partial<T>) {
    const before = this.rows.length;
    this.rows = this.rows.filter((r) => !this.matches(r, where));
    return Promise.resolve({ affected: before - this.rows.length });
  }
}
