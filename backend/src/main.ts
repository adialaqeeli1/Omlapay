import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { VersioningType } from '@nestjs/common';
// eslint-disable-next-line @typescript-eslint/no-require-imports
import ExpressBasicAuth = require('express-basic-auth');
import { SwaggerConfig } from './common/utils/constants';
import { ValidationPipe } from './common/pipes/validation.pipe';
import { AllExceptionsFilter } from './common/filters/error.filter';
import { LoggingInterceptor } from './common/interceptors';
async function bootstrap() {
  // rawBody: true enables req.rawBody (Buffer) for webhook signature verification.
  // Do NOT use bodyParser: false - it causes "stream encoding should not be set" errors.
  const app = await NestFactory.create(AppModule, {
    rawBody: true,
  });

  // Enable API versioning
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  // Global Validation Pipe
  app.useGlobalPipes(new ValidationPipe());

  // Global Interceptors
  app.useGlobalInterceptors(new LoggingInterceptor());

  // Swagger Configuration with Basic Auth Protection
  const swaggerUser = process.env.SWAGGER_USER;
  const swaggerPassword = process.env.SWAGGER_PASSWORD;
  if (!swaggerUser || !swaggerPassword || !swaggerUser.trim() || !swaggerPassword.trim()) {
    throw new Error('SWAGGER_USER and SWAGGER_PASSWORD must be set.');
  }
  const effectiveSwaggerUser = swaggerUser?.trim();
  const effectiveSwaggerPassword = swaggerPassword?.trim();

  app.use(
    ['/docs', '/docs-json'],
    ExpressBasicAuth({
      challenge: true,
      users: {
        [effectiveSwaggerUser as string]: effectiveSwaggerPassword as string,
      },
    }),
  );

  const config = new DocumentBuilder()
    .setTitle(SwaggerConfig.DOCS_TITLE)
    .setDescription(SwaggerConfig.DOCS_DESCRIPTION)
    .setVersion(SwaggerConfig.DOCS_VERSION)
    .addBearerAuth({
      description: `[just text field] Please enter token in following format: Bearer <JWT>`,
      name: 'Authorization',
      bearerFormat: 'Bearer',
      scheme: 'Bearer',
      type: 'http',
      in: 'Header',
    })
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup(SwaggerConfig.DOCS_ENDPOINT, app, document);

  app.useGlobalFilters(new AllExceptionsFilter());
  app.enableCors({
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
    credentials: true,
  });
  const port = process.env.PORT || 3000;
  await app.listen(port);
}

bootstrap().catch((err) => {
  console.error('Application bootstrap failed:', err instanceof Error ? err.message : err);
  process.exit(1);
});
