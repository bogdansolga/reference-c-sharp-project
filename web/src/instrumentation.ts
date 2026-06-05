// Next.js calls register() once when the server boots. The actual checks live
// in ./instrumentation-node — dynamically imported only on the Node.js runtime
// (the Edge runtime has no filesystem), so Turbopack doesn't bundle node:* for Edge.
export async function register() {
  if (process.env.NEXT_RUNTIME === "nodejs") {
    const { checkChatConfig } = await import("./instrumentation-node");
    checkChatConfig();
  }
}
