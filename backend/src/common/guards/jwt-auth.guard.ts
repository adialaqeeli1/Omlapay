import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuthSessionEntity } from '@common/database/model/auth-session.entity';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private jwtService: JwtService,
    @InjectRepository(AuthSessionEntity)
    private authSessionRepository: Repository<AuthSessionEntity>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;

    if (!authHeader) {
      throw new UnauthorizedException({
        status: 'error',
        message: 'Authorization header is missing.',
      });
    }

    const [bearer, token] = authHeader.split(' ');

    if (bearer !== 'Bearer' || !token) {
      throw new UnauthorizedException({
        status: 'error',
        message: 'Invalid authorization format.',
      });
    }

    try {
      const payload = this.jwtService.verify(token);

      // Check if token is an access token
      if (payload.type !== 'access') {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Invalid token type.',
        });
      }

      // Check if session exists and is not revoked
      if (payload.sessionId) {
        const session = await this.authSessionRepository.findOne({
          where: { id: payload.sessionId },
        });

        if (!session) {
          throw new UnauthorizedException({
            status: 'error',
            message: 'Session not found.',
          });
        }

        if (session.isRevoked) {
          throw new UnauthorizedException({
            status: 'error',
            message: 'Session has been revoked.',
          });
        }

        if (session.expiresAt < new Date()) {
          throw new UnauthorizedException({
            status: 'error',
            message: 'Session has expired.',
          });
        }

        if (session.userId !== payload.userId) {
          throw new UnauthorizedException({
            status: 'error',
            message: 'Session does not match token.',
          });
        }
      }

      request.user = payload;
      return true;
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException({
        status: 'error',
        message: 'Invalid or expired token.',
      });
    }
  }
}
