import Image from "next/image";
import Link from "next/link";
import { LogoutButton } from "@/app/logout-button";
import { getSession } from "@/lib/auth";

export async function SiteHeader() {
  const session = await getSession();

  return (
    <header className="bg-brand-ink text-white">
      <div className="mx-auto flex max-w-5xl items-center justify-between px-6 py-3">
        <Link className="flex items-center gap-3" href="/">
          <span className="overflow-hidden rounded-lg bg-white">
            <Image
              alt=""
              className="h-9 w-9 object-cover"
              height={36}
              src="/zempler-logo.png"
              style={{ objectPosition: "center 22%" }}
              width={36}
            />
          </span>
          <span className="font-bold font-display text-lg tracking-tight">Zempler Bank</span>
        </Link>

        <nav aria-label="Main navigation" className="flex items-center gap-5 text-sm">
          <Link className="font-medium text-zinc-300 transition-colors hover:text-brand-spark" href="/section">
            Sections
          </Link>
          <Link className="font-medium text-zinc-300 transition-colors hover:text-brand-spark" href="/product">
            Products
          </Link>
          {session ? (
            <div className="flex items-center gap-3 border-white/15 border-l pl-5">
              <span className="text-zinc-400">
                {session.user.username} <span className="text-brand-spark">({session.user.role})</span>
              </span>
              <LogoutButton />
            </div>
          ) : (
            <Link
              className="rounded-md bg-brand-accent px-3 py-1.5 font-semibold text-white transition-colors hover:bg-brand-spark hover:text-brand-ink"
              href="/login"
            >
              Login
            </Link>
          )}
        </nav>
      </div>
    </header>
  );
}
