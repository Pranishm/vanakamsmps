import { NextResponse } from 'next/server';
import mongoose from 'mongoose';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

export async function GET() {
  const mongoUri = process.env.MONGODB_URI || '';
  let dbStatus = 'not tested';

  try {
    if (mongoUri) {
      // Test connection with a 5-second timeout
      const conn = await mongoose.connect(mongoUri, {
        serverSelectionTimeoutMS: 5000,
      });
      dbStatus = `connected (readyState: ${conn.connection.readyState})`;
      // Disconnect the test connection
      if (conn.connection.readyState === 1) {
        await conn.disconnect();
      }
    } else {
      dbStatus = 'MONGODB_URI is empty';
    }
  } catch (e: any) {
    dbStatus = `FAILED: ${e.message}`;
  }

  return NextResponse.json({
    NEXTAUTH_URL: process.env.NEXTAUTH_URL || '❌ NOT SET',
    NEXTAUTH_SECRET: process.env.NEXTAUTH_SECRET ? '✅ SET' : '❌ NOT SET',
    NEXTAUTH_TRUST_HOST: process.env.NEXTAUTH_TRUST_HOST || '❌ NOT SET',
    MONGODB_URI: mongoUri
      ? `✅ SET (${mongoUri.substring(0, 20)}...)`
      : '❌ NOT SET',
    MONGODB_DB_STATUS: dbStatus,
    NODE_ENV: process.env.NODE_ENV || 'unknown',
  });
}
