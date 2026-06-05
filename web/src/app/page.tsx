import Image from "next/image";
import Link from "next/link";
import { Suspense } from "react";
import { ChatWidget } from "@/components/chat-widget";
import { getSession } from "@/lib/auth";

async function HeroActions() {
  const session = await getSession();

  if (session) {
    return (
      <div className="flex flex-col items-center gap-3">
        <p className="text-sm text-zinc-500">
          Signed in as <span className="font-semibold text-brand-ink">{session.user.username}</span> (
          {session.user.role})
        </p>
        <div className="flex gap-3">
          <Link
            className="rounded-lg bg-brand-accent px-5 py-2.5 font-semibold text-white transition-colors hover:bg-brand-ink"
            href="/section"
          >
            Browse Sections
          </Link>
          <Link
            className="rounded-lg border border-border-soft bg-surface px-5 py-2.5 font-semibold text-brand-ink transition-colors hover:border-brand-accent"
            href="/product"
          >
            Browse Products
          </Link>
        </div>
      </div>
    );
  }

  return (
    <Link
      className="rounded-lg bg-brand-accent px-6 py-3 font-semibold text-white transition-colors hover:bg-brand-ink"
      href="/login"
    >
      Get started
    </Link>
  );
}

export default function Home() {
  return (
    <main className="flex min-h-[calc(100vh-64px)] flex-col items-center justify-center px-6 py-16">
      <Image alt="Zempler Bank" className="mb-8" height={120} priority src="/zempler-logo.png" width={120} />
      <h1 className="text-center font-bold font-display text-4xl tracking-tight sm:text-5xl">
        Product &amp; Section Management
      </h1>
      <p className="mt-3 max-w-md text-center text-zinc-500">
        A small showcase API and UI for the Mastering Claude Code course. Sign in to browse the catalog.
      </p>

      <div className="mt-8">
        <Suspense fallback={<div className="h-12" />}>
          <HeroActions />
        </Suspense>
      </div>

      <ChatWidget />
    </main>
  );
}
