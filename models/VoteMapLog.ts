import mongoose, { Schema, models } from 'mongoose';

export interface IVoteMapLog {
  _id: string;
  userId: string;
  mapId: string;
  createdAt: Date;
  updatedAt: Date;
}

const VoteMapLogSchema = new Schema<IVoteMapLog>({
  userId: { type: String, required: true },
  mapId: { type: String, required: true }
}, { timestamps: true });

// Ensure a user can only have ONE active map vote at a time
VoteMapLogSchema.index({ userId: 1 }, { unique: true });

export default models.VoteMapLog || mongoose.model<IVoteMapLog>('VoteMapLog', VoteMapLogSchema);
