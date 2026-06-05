import { cookies } from "next/headers";
import { Suspense } from "react";
import type { ProductResponse } from "@/lib/types/product";

async function ProductList() {
  const cookieStore = await cookies();
  const response = await fetch(`${process.env.API_URL || "http://localhost:5099"}/api/v1/product`, {
    headers: { Cookie: cookieStore.toString() },
    cache: "no-store",
  });
  const products: ProductResponse[] = response.ok ? await response.json() : [];

  if (products.length === 0) {
    return (
      <div className="rounded-xl border border-border-soft border-dashed bg-surface p-10 text-center text-zinc-500">
        No products yet.
      </div>
    );
  }

  return (
    <ul className="space-y-2">
      {products.map((product, i) => (
        <li
          className="row-reveal flex items-center justify-between rounded-xl border border-border-soft bg-surface px-4 py-3 shadow-sm"
          key={product.id}
          style={{ animationDelay: `${i * 40}ms` }}
        >
          <span className="font-medium">{product.name}</span>
          <span className="rounded-full bg-badge-bg px-2.5 py-1 font-semibold text-brand-accent text-sm">
            ${product.price.toFixed(2)}
          </span>
        </li>
      ))}
    </ul>
  );
}

export default function ProductsPage() {
  return (
    <main className="mx-auto max-w-2xl px-6 py-10">
      <h1 className="mb-6 font-bold font-display text-3xl tracking-tight">Products</h1>
      <Suspense
        fallback={
          <ul className="space-y-2">
            {[1, 2, 3].map((n) => (
              <li className="h-[50px] animate-pulse rounded-xl border border-border-soft bg-surface" key={n} />
            ))}
          </ul>
        }
      >
        <ProductList />
      </Suspense>
    </main>
  );
}
