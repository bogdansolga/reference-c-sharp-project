import { cookies } from "next/headers";
import Link from "next/link";
import { Suspense } from "react";
import type { ProductResponse } from "@/lib/types/product";

async function ProductList() {
  const cookieStore = await cookies();
  const response = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000"}/api/v1/product`, {
    headers: { Cookie: cookieStore.toString() },
  });
  const products: ProductResponse[] = response.ok ? await response.json() : [];

  if (products.length === 0) {
    return <p className="text-zinc-500">No products found.</p>;
  }

  return (
    <ul className="space-y-2">
      {products.map((product) => (
        <li className="flex items-center justify-between rounded-md border p-3 dark:border-zinc-700" key={product.id}>
          <span>{product.name}</span>
          <span className="text-zinc-600 dark:text-zinc-400">${product.price.toFixed(2)}</span>
        </li>
      ))}
    </ul>
  );
}

export default function ProductsPage() {
  return (
    <main className="mx-auto min-h-screen max-w-2xl p-8">
      <div className="mb-6 flex items-center justify-between">
        <h1 className="font-semibold text-2xl">Products</h1>
        <Link
          className="text-sm text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100"
          href="/"
        >
          ← Back
        </Link>
      </div>

      <Suspense fallback={<p className="text-zinc-500">Loading...</p>}>
        <ProductList />
      </Suspense>
    </main>
  );
}
