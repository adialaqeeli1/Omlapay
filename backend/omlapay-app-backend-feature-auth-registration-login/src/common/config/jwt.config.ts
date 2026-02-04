import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModuleAsyncOptions } from '@nestjs/jwt';

export const jwtConfig = (expiresIn: string = '24h'): JwtModuleAsyncOptions => ({
  imports: [ConfigModule],
  useFactory: (configService: ConfigService) => {
    const secret = configService.get<string>('JWT_SECRET_KEY');
    return {
      secret,
      signOptions: { expiresIn },
    };
  },
  inject: [ConfigService],
});

