"use client";

import { LogOut } from "lucide-react";
import { useRouter } from "next/navigation";

export function LogoutButton() {
  const router = useRouter();

  async function handleLogout() {
    await fetch("/api/auth/logout", { method: "POST" });
    router.push("/login");
    router.refresh();
  }

  return (
    <button
      className="flex items-center gap-1.5 text-sm text-zinc-400 transition-colors hover:text-brand-spark"
      onClick={handleLogout}
      type="button"
    >
      <LogOut className="h-4 w-4" />
      Logout
    </button>
  );
}
