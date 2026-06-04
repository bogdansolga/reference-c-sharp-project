import { cookies } from "next/headers";
import Link from "next/link";
import { Suspense } from "react";
import type { SectionResponse } from "@/lib/types/section";

async function SectionList() {
  const cookieStore = await cookies();
  const response = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000"}/api/v1/section`, {
    headers: { Cookie: cookieStore.toString() },
  });
  const sections: SectionResponse[] = response.ok ? await response.json() : [];

  if (sections.length === 0) {
    return <p className="text-zinc-500">No sections found.</p>;
  }

  return (
    <ul className="space-y-2">
      {sections.map((section) => (
        <li className="rounded-md border p-3 dark:border-zinc-700" key={section.id}>
          {section.name}
        </li>
      ))}
    </ul>
  );
}

export default function SectionsPage() {
  return (
    <main className="mx-auto min-h-screen max-w-2xl p-8">
      <div className="mb-6 flex items-center justify-between">
        <h1 className="font-semibold text-2xl">Sections</h1>
        <Link
          className="text-sm text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100"
          href="/"
        >
          ← Back
        </Link>
      </div>

      <Suspense fallback={<p className="text-zinc-500">Loading...</p>}>
        <SectionList />
      </Suspense>
    </main>
  );
}
