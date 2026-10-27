import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import pinoHttp from 'pino-http';
import { logger } from './core/logger.js';
import { config } from './core/config.js';
import { requestIdMiddleware } from './middleware/requestId.js';
import { errorHandler } from './middleware/errorHandler.js';
import { notImplemented } from './middleware/notImplemented.js';
import { AppError, ErrorCodes } from './core/errors.js';

import { systemRouter } from './routes/system.routes.js';
import { authRouter } from './routes/auth.routes.js';
import { catalogueRouter } from './routes/catalogue.routes.js';
import { listingRouter } from './routes/listing.routes.js';
import { tradeRouter } from './routes/trade.routes.js';
import { orderRouter } from './routes/order.routes.js';
import { messageRouter } from './routes/message.routes.js';
import { searchRouter } from './routes/search.routes.js';
import { deliveryRouter } from './routes/delivery.routes.js';
import { barterRouter } from './routes/barter.routes.js';
import { shopRouter } from './routes/shop.routes.js';
import { adminRouter } from './routes/admin.routes.js';

export const app = express();

// Trust proxy headers (needed for correct req.ip behind Vercel / reverse proxy)
app.set('trust proxy', 1);

app.use(requestIdMiddleware);

app.use(pinoHttp({
  logger,
  customLogLevel: (req, res, err) => {
    if (res.statusCode >= 500 || err) return 'error';
    if (res.statusCode >= 400) return 'warn';
    return 'info';
  },
  serializers: {
    req: (req) => ({
      id: req.id,
      method: req.method,
      url: req.url
    })
  }
}));

app.use(helmet());

const corsOptions = config.CORS_ORIGINS
  ? { origin: config.CORS_ORIGINS.split(',').map(s => s.trim()) }
  : { origin: true }; // Allow mobile apps / localhost

app.use(cors(corsOptions));
app.use(express.json({ limit: '100kb' }));

// Mount API v1 Routes
const apiV1 = express.Router();

apiV1.use('/', systemRouter);
apiV1.use('/auth', authRouter);
apiV1.use('/', catalogueRouter);
apiV1.use('/listings', listingRouter);
apiV1.use('/requests', tradeRouter);
apiV1.use('/orders', orderRouter);
apiV1.use('/messages', messageRouter);
apiV1.use('/search', searchRouter);
apiV1.use('/shop', shopRouter);
apiV1.use('/delivery-partners', deliveryRouter);
apiV1.use('/deliveries', deliveryRouter);
apiV1.use('/barter-requests', barterRouter);
apiV1.use('/admin', adminRouter);

// Phase B4 Planned endpoints (501 NOT_IMPLEMENTED contract)
apiV1.use('/images', notImplemented('Photo uploads and image storage', 'B4'));
apiV1.use('/reviews', notImplemented('Reviews and ratings aggregation', 'B4'));
apiV1.use('/impact', notImplemented('Impact computation and dashboard metrics', 'B4'));

app.use('/api/v1', apiV1);

// 404 Route handler
app.use((req, res, next) => {
  next(new AppError(ErrorCodes.NOT_FOUND, `Route '${req.method} ${req.originalUrl}' not found`, 404));
});

// Centralized error handling
app.use(errorHandler);
