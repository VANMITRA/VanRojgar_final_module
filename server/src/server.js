import { app } from './app.js';
import { config } from './core/config.js';
import { logger } from './core/logger.js';
import { connectDB, disconnectDB } from './core/db.js';
import { RateLimit } from './models/RateLimit.js';

async function bootstrap() {
  try {
    if (process.argv.includes('--embedded-db') || process.env.USE_EMBEDDED_DB === 'true') {
      if (config.NODE_ENV === 'production') throw new Error('Embedded database is for local development only');
      const { startEmbeddedDb } = await import('./core/embeddedDb.js');
      const embedded = await startEmbeddedDb();
      config.MONGODB_URI = embedded.uri;
      process.on('SIGINT', () => embedded.stop().finally(() => process.exit(0)));
    }
    await connectDB();
    if (config.NODE_ENV === 'development') {
      await RateLimit.deleteMany({ key: /^login:/ }).catch(() => {});
      logger.info('🧹 Cleared development login rate limit locks');
    }
    const server = app.listen(config.PORT, '0.0.0.0', () => {
      logger.info(`🚀 VanRozgar Server listening on port ${config.PORT} [${config.NODE_ENV}]`);
      logger.info(`📡 API endpoint: http://localhost:${config.PORT}/api/v1`);
    });

    const shutdown = async (signal) => {
      logger.info(`Received ${signal}. Shutting down gracefully...`);
      server.close(async () => {
        await disconnectDB();
        process.exit(0);
      });
    };

    process.on('SIGINT', () => shutdown('SIGINT'));
    process.on('SIGTERM', () => shutdown('SIGTERM'));
  } catch (err) {
    logger.fatal({ err }, 'Failed to bootstrap server');
    process.exit(1);
  }
}

bootstrap();
