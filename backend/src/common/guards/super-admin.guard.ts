import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AdminEntity, AdminRole } from '../database/model/admin.entity';

@Injectable()
export class SuperAdminGuard implements CanActivate {
  constructor(
    @InjectRepository(AdminEntity)
    private adminRepository: Repository<AdminEntity>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const adminId = request.adminId;

    if (!adminId) {
      throw new ForbiddenException('Admin ID not found in request');
    }

    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin) {
      throw new ForbiddenException('Admin not found');
    }

    if (admin.role !== AdminRole.SUPER_ADMIN) {
      throw new ForbiddenException('Access denied. Super Admin role required.');
    }

    return true;
  }
}
