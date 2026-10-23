import mongoose from 'mongoose';

const AuditLogSchema = new mongoose.Schema({
  actorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  action: { type: String, required: true },
  targetType: { type: String, required: true },
  targetId: { type: mongoose.Schema.Types.ObjectId, required: true },
  note: { type: String, trim: true },
  metadata: { type: mongoose.Schema.Types.Mixed }
}, {
  timestamps: true
});

AuditLogSchema.index({ targetType: 1, targetId: 1 });
AuditLogSchema.index({ actorId: 1, createdAt: -1 });

export const AuditLog = mongoose.models.AuditLog || mongoose.model('AuditLog', AuditLogSchema);
