"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

export default function LoginPage() {
  const router = useRouter();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const res = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
      });

      const data = await res.json();

      if (!res.ok) {
        setError(data.error || "Login failed");
        return;
      }

      router.push("/");
      router.refresh();
    } catch {
      setError("An error occurred");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="flex min-h-[calc(100vh-64px)] items-center justify-center px-6 py-16">
      <div className="w-full max-w-sm rounded-2xl border border-border-soft bg-surface p-8 shadow-sm">
        <h1 className="mb-1 text-center font-bold font-display text-2xl tracking-tight">Sign in</h1>
        <p className="mb-6 text-center text-sm text-zinc-500">Welcome back to Zempler Bank</p>

        <form className="space-y-4" onSubmit={handleSubmit}>
          <div>
            <label className="mb-1 block font-medium text-sm" htmlFor="username">
              Username
            </label>
            <input
              className="w-full rounded-lg border border-border-soft px-3 py-2 outline-none transition focus:border-brand-accent focus:ring-2 focus:ring-brand-spark"
              id="username"
              onChange={(e) => setUsername(e.target.value)}
              required
              type="text"
              value={username}
            />
          </div>

          <div>
            <label className="mb-1 block font-medium text-sm" htmlFor="password">
              Password
            </label>
            <input
              className="w-full rounded-lg border border-border-soft px-3 py-2 outline-none transition focus:border-brand-accent focus:ring-2 focus:ring-brand-spark"
              id="password"
              onChange={(e) => setPassword(e.target.value)}
              required
              type="password"
              value={password}
            />
          </div>

          {error && <p className="text-red-600 text-sm">{error}</p>}

          <button
            className="w-full rounded-lg bg-brand-accent px-4 py-2.5 font-semibold text-white transition-colors hover:bg-brand-ink disabled:opacity-50"
            disabled={loading}
            type="submit"
          >
            {loading ? "Signing in…" : "Sign in"}
          </button>
        </form>

        <div className="mt-6 rounded-lg bg-badge-bg px-3 py-2 text-center text-sm text-zinc-600">
          <p className="font-medium text-brand-ink">Test credentials</p>
          <p className="font-mono text-xs">user / user · admin / admin</p>
        </div>
      </div>
    </main>
  );
}
