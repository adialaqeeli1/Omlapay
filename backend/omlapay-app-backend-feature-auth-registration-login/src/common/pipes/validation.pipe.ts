import {
  PipeTransform,
  Injectable,
  ArgumentMetadata,
  BadRequestException,
} from '@nestjs/common';
import { validate, ValidationError } from 'class-validator';
import { plainToInstance } from 'class-transformer';

@Injectable()
export class ValidationPipe implements PipeTransform<any> {
  async transform(value: unknown, { metatype }: ArgumentMetadata) {
    if (!metatype || !this.toValidate(metatype)) {
      return value;
    }
    const object = plainToInstance(metatype, value);
    const errors = await validate(object);
    if (errors.length > 0) {
      const msg = this.formatError(errors);
      throw new BadRequestException(msg);
    }

    value = this.trim(value);
    return value;
  }

  private toValidate(metatype: unknown): boolean {
    const types = [String, Boolean, Number, Array, Object];
    return !types.includes(metatype as unknown as never);
  }

  private isEmpty(value: unknown): boolean {
    if (!this.isObj(value)) return false;
    return Object.keys(value as Record<string, unknown>).length < 1;
  }

  private isObj(obj: unknown): boolean {
    return typeof obj === 'object' && obj !== null;
  }

  private trim(values: unknown): unknown {
    if (!this.isObj(values)) return values;

    const obj = values as Record<string, unknown>;
    Object.keys(obj).forEach((key) => {
      if (key !== 'password') {
        if (this.isObj(obj[key])) {
          obj[key] = this.trim(obj[key]);
        } else {
          if (typeof obj[key] === 'string') {
            obj[key] = (obj[key] as string).trim();
          }
        }
      }
    });
    return obj;
  }

  private formatError(errors: ValidationError[]) {
    const messages: string[] = [];

    errors.forEach((error) => {
      if (error.constraints) {
        messages.push(...Object.values(error.constraints));
      }
    });

    return messages.join('; ') || 'Validation failed';
  }
}
