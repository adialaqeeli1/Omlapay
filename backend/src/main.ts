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
import { json } from 'express';

async function bootstrap() {
  // Create app with raw body enabled for specific routes
  const app = await NestFactory.create(AppModule, {
    bodyParser: false, // Disable default body parser to add our custom one
  });

  // Custom middleware to capture raw body for webhook signature verification
  app.use((req: any, res: any, next: any) => {
    if (req.originalUrl?.includes('webhooks/sumsub') ?? req.path?.includes('webhooks/sumsub')) {
      let data = '';
      req.setEncoding('utf8');
      req.on('data', (chunk: string) => {
        data += chunk;
      });
      req.on('end', () => {
        req.rawBody = data;
        // Parse JSON manually
        try {
          req.body = JSON.parse(data);
        } catch (e) {
          req.body = {};
        }
        next();
      });
    } else {
      next();
    }
  });

  // Add default JSON parser for all other routes
  app.use(json());

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
  const swaggerUser = process.env.SWAGGER_USER || 'admin';
  const swaggerPassword = process.env.SWAGGER_PASSWORD || 'admin';

  app.use(
    ['/docs', '/docs-json'],
    ExpressBasicAuth({
      challenge: true,
      users: {
        [swaggerUser]: swaggerPassword,
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
void bootstrap();
