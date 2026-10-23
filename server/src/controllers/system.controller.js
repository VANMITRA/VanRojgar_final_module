import mongoose from 'mongoose';
import { CURRENT_PHASE, COMPONENTS, NOTICES } from '../core/phases.js';
import { config } from '../core/config.js';
import { successEnvelope } from '../core/serializers.js';

export class SystemController {
  static async health(req, res) {
    const start = Date.now();
    let dbStatus = 'disconnected';
    let dbLatencyMs = null;

    try {
      if (mongoose.connection.readyState === 1 && mongoose.connection.db) {
        await mongoose.connection.db.admin().ping();
        dbStatus = 'connected';
        dbLatencyMs = Date.now() - start;
      }
    } catch {
      dbStatus = 'error';
    }

    const isHealthy = dbStatus === 'connected';
    const status = isHealthy ? 200 : 503;

    return res.status(status).json(successEnvelope({
      status: isHealthy ? 'healthy' : 'degraded',
      phase: CURRENT_PHASE,
      uptimeSeconds: Math.floor(process.uptime()),
      db: {
        status: dbStatus,
        latencyMs: dbLatencyMs
      }
    }));
  }

  static async meta(req, res) {
    return res.json(successEnvelope({
      product: 'VanRozgar',
      phase: CURRENT_PHASE,
      gitSha: config.GIT_SHA,
      components: COMPONENTS,
      notices: NOTICES,
      bulkThresholds: config.bulkThresholds,
      categoriesVersion: '2026.1'
    }));
  }
}
