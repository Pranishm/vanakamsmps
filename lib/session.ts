import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';

export async function getSession() {
  return await getServerSession(authOptions);
}

export async function getCurrentUser() {
  const session = await getSession();
  
  // Mobile Bridge: If no session cookie, check for trusted headers (Flutter app dev)
  if (!session?.user) {
    const { headers } = await import('next/headers');
    const h = await headers();
    const email = h.get('x-user-email');
    const role = h.get('x-user-role');
    const name = h.get('x-user-name') || email?.split('@')[0];
    const id = h.get('x-user-id');

    if (email && role) {
      return { 
        email, 
        role, 
        name: name ?? undefined, 
        id: id ?? undefined 
      };
    }
  }

  return session?.user;
}

export async function requireAuth() {
  const user = await getCurrentUser();
  if (!user) {
    throw new Error('Unauthorized');
  }
  return user;
}

export async function requireOwner() {
  const user = await requireAuth();
  if (user.role !== 'OWNER') {
    throw new Error('Forbidden: Owner access required');
  }
  return user;
}

export async function requireAdmin() {
  const user = await requireAuth();
  if (user.role !== 'ADMIN' && user.role !== 'OWNER') {
    throw new Error('Forbidden: Admin access required');
  }
  return user;
}

export async function requireStaff() {
  const user = await requireAuth();
  if (user.role !== 'ADMIN' && user.role !== 'STAFF' && user.role !== 'OWNER') {
    throw new Error('Forbidden: Staff access required');
  }
  return user;
}
