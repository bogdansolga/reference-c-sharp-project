import { cookies } from "next/headers";
import { Suspense } from "react";
import type { SectionResponse } from "@/lib/types/section";

async function SectionList() {
  const cookieStore = await cookies();
  const response = await fetch(`${process.env.API_URL || "http://localhost:5099"}/api/v1/section`, {
    headers: { Cookie: cookieStore.toString() },
    cache: "no-store",
  });
  const sections: SectionResponse[] = response.ok ? await response.json() : [];

  if (sections.length === 0) {
    return (
      <div className="rounded-xl border border-border-soft border-dashed bg-surface p-10 text-center text-zinc-500">
        No sections yet.
      </div>
    );
  }

  return (
    <ul className="space-y-2">
      {sections.map((section, i) => (
        <li
          className="row-reveal rounded-xl border border-border-soft bg-surface px-4 py-3 font-medium shadow-sm"
          key={section.id}
          style={{ animationDelay: `${i * 40}ms` }}
        >
          {section.name}
        </li>
      ))}
    </ul>
  );
}

export default function SectionsPage() {
  return (
    <main className="mx-auto max-w-2xl px-6 py-10">
      <h1 className="mb-6 font-bold font-display text-3xl tracking-tight">Sections</h1>
      <Suspense fallback={<p className="text-zinc-400">Loading…</p>}>
        <SectionList />
      </Suspense>
    </main>
  );
}
