import mongoose, { Schema, models } from 'mongoose';

export interface IVoteMap {
  _id: string;
  title: string;
  description: string;
  image: string;
  isActive: boolean;
  votesCount: number;
  createdAt: Date;
  updatedAt: Date;
}

const VoteMapSchema = new Schema<IVoteMap>({
  title: { type: String, required: true },
  description: { type: String, default: '' },
  image: { type: String, default: '' },
  isActive: { type: Boolean, default: true },
  votesCount: { type: Number, default: 0 }
}, { timestamps: true });

export default models.VoteMap || mongoose.model<IVoteMap>('VoteMap', VoteMapSchema);
