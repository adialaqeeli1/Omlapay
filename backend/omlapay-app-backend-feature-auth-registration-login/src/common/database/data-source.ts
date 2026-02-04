import { config } from 'dotenv';
config();
import { DataSource, DataSourceOptions } from 'typeorm';
export const dataSourceOptions: DataSourceOptions = {
  type: 'postgres',
  host: process.env.POSTGRES_HOST,
  port: process.env.POSTGRES_PORT ? +process.env.POSTGRES_PORT : 5432,
  username: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
  synchronize: false,
  migrationsRun: true,
  migrations: ['dist/database/migrations/*{.ts,.js}'],
  entities: [__dirname + '/../**/*.entity{.ts,.js}'],
};

// The DataSource constructor is well-typed by TypeORM, but ESLint cannot infer it correctly here.
// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call
const dataSource: DataSource = new DataSource(dataSourceOptions);
export default dataSource;
