import { readFileSync } from "node:fs";
import { join } from "node:path";
import { anthropic } from "@ai-sdk/anthropic";
import { convertToModelMessages, streamText } from "ai";

const systemPrompt = readFileSync(join(process.cwd(), "src/prompts/chat-system.md"), "utf-8");

// Claude by default (the course is about Claude Code). Override with CHAT_MODEL.
const chatModel = process.env.CHAT_MODEL || "claude-haiku-4-5";

export async function POST(req: Request) {
  if (!process.env.ANTHROPIC_API_KEY) {
    return new Response("The ANTHROPIC_API_KEY environment variable is not configured", { status: 500 });
  }

  const { messages } = await req.json();

  const result = streamText({
    model: anthropic(chatModel),
    system: systemPrompt,
    messages: await convertToModelMessages(messages),
  });

  return result.toUIMessageStreamResponse();
}
