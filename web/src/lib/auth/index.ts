import { cookies } from "next/headers";

/**
 * Frontend session reader. The session is established by the C# API (POST /api/auth/login),
 * which sets an httpOnly "session" cookie containing {id, username, role} as JSON.
 * Server components read it here to render auth state; login/logout go to the C# API.
 */
export interface Session {
  user: { id: string; username: string; role: string };
}

const SESSION_COOKIE = "session";

export async function getSession(): Promise<Session | null> {
  try {
    const cookieStore = await cookies();
    const session = cookieStore.get(SESSION_COOKIE);
    if (!session?.value) {
      return null;
    }

    const data = JSON.parse(session.value);
    return { user: data };
  } catch {
    return null;
  }
}
