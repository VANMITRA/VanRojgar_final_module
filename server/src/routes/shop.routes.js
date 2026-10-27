import { Router } from 'express';
import { ShopController } from '../controllers/shop.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { validate } from '../middleware/validate.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { idempotencyMiddleware } from '../middleware/idempotency.js';
import { config, parseRateLimit } from '../core/config.js';
import { productsQuerySchema, sellersQuerySchema, stockQuerySchema, cartCheckoutSchema } from '../validators/shop.schema.js';

export const shopRouter = Router();

const browseLimit = parseRateLimit(config.RATE_LIMIT_SEARCH, 120, 60);
const browse = rateLimit({ keyPrefix: 'shop', max: browseLimit.max, windowSeconds: browseLimit.windowSeconds });

// Browsing is open to guests: no sign-in. Signing in is asked only at checkout.
shopRouter.get('/home', browse, ShopController.home);
shopRouter.get('/products', browse, validate(productsQuerySchema, 'query'), ShopController.products);
shopRouter.get('/products/:code/sellers', browse, validate(sellersQuerySchema, 'query'), ShopController.sellers);
shopRouter.get('/stock', browse, validate(stockQuerySchema, 'query'), ShopController.stock);

// Cart checkout: one request per product and seller (each seller approves or counters on their own)
shopRouter.post('/cart/checkout', authenticate, idempotencyMiddleware(), validate(cartCheckoutSchema), ShopController.checkout);
