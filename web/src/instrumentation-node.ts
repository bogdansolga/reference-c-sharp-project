import { existsSync } from "node:fs";
import { join } from "node:path";

// Node.js-only startup checks for the chat widget. We only warn — a missing key
// shouldn't block the app, just the chat (POST /api/chat returns 500 until
// ANTHROPIC_API_KEY is configured). Imported by instrumentation.ts on the Node runtime.
export function checkChatConfig() {
  if (!existsSync(join(process.cwd(), ".env"))) {
    // biome-ignore lint/suspicious/noConsole: startup diagnostics for missing config
    console.warn("⚠ web/.env not found — copy .env.example to .env and set ANTHROPIC_API_KEY for the chat widget.");
  }

  if (!process.env.ANTHROPIC_API_KEY) {
    // biome-ignore lint/suspicious/noConsole: startup diagnostics for missing config
    console.warn(
      "⚠ ANTHROPIC_API_KEY is not set — the chat widget (POST /api/chat) will return 500 until it is configured."
    );
  }
}
