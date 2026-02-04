import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { AdminAuthService } from '../../api/v1/admin-auth/admin-auth.service';

@Injectable()
export class AdminJwtAuthGuard implements CanActivate {
  constructor(private adminAuthService: AdminAuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid authorization header');
    }

    const token = authHeader.substring(7);

    try {
      const adminId = await this.adminAuthService.validateSession(token);
      request.adminId = adminId;
      return true;
    } catch (error) {
      throw new UnauthorizedException('Invalid or expired session');
    }
  }
}

