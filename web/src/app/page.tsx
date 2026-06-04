import Link from "next/link";
import { Suspense } from "react";
import { ChatWidget } from "@/components/chat-widget";
import { getSession } from "@/lib/auth";
import { LogoutButton } from "./logout-button";

async function AuthStatus() {
  const session = await getSession();

  if (session) {
    return (
      <div className="text-center">
        <p className="text-sm text-zinc-600 dark:text-zinc-400">
          Logged in as <span className="font-semibold">{session.user.username}</span> ({session.user.role})
        </p>
        <div className="mt-4 flex gap-4">
          <Link
            className="rounded-md bg-zinc-900 px-4 py-2 text-white hover:bg-zinc-800 dark:bg-zinc-100 dark:text-zinc-900 dark:hover:bg-zinc-200"
            href="/section"
          >
            Sections
          </Link>
          <Link
            className="rounded-md bg-zinc-900 px-4 py-2 text-white hover:bg-zinc-800 dark:bg-zinc-100 dark:text-zinc-900 dark:hover:bg-zinc-200"
            href="/product"
          >
            Products
          </Link>
        </div>
        <LogoutButton />
      </div>
    );
  }

  return (
    <Link
      className="rounded-md bg-zinc-900 px-4 py-2 text-white hover:bg-zinc-800 dark:bg-zinc-100 dark:text-zinc-900 dark:hover:bg-zinc-200"
      href="/login"
    >
      Login
    </Link>
  );
}

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-8">
      <h1 className="font-semibold text-2xl">Product API</h1>
      <p className="mt-2 text-zinc-600 dark:text-zinc-400">The API endpoints are available at /api/v1</p>

      <div className="mt-6">
        <Suspense fallback={<div className="h-10" />}>
          <AuthStatus />
        </Suspense>
      </div>
      <ChatWidget />
    </main>
  );
}
