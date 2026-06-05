"use client";

import { useChat } from "@ai-sdk/react";
import { DefaultChatTransport } from "ai";
import { MessageCircle, X } from "lucide-react";
import { type FormEvent, useState } from "react";
import Markdown from "react-markdown";

export function ChatWidget() {
  const [isOpen, setIsOpen] = useState(false);
  const [inputValue, setInputValue] = useState("");
  const { messages, sendMessage, status, error } = useChat({
    transport: new DefaultChatTransport({ api: "/api/chat" }),
  });
  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    if (inputValue.trim() && status === "ready") {
      void sendMessage({ text: inputValue });
      setInputValue("");
    }
  };

  return (
    <div className="fixed right-4 bottom-4 z-60">
      {isOpen ? (
        <div className="flex h-[28rem] w-lg flex-col overflow-hidden rounded-2xl border border-border-soft bg-surface shadow-xl">
          <div className="flex items-center justify-between bg-brand-ink px-4 py-3 text-white">
            <span className="font-bold font-display tracking-tight">Ask AI</span>
            <button
              className="text-zinc-300 transition-colors hover:text-brand-spark"
              onClick={() => setIsOpen(false)}
              type="button"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
          <div className="flex-1 space-y-3 overflow-y-auto p-4">
            {messages.map((m) => (
              <div className={`text-base ${m.role === "user" ? "text-right" : "text-left"}`} key={m.id}>
                <div
                  className={`inline-block max-w-full rounded-2xl px-3 py-2 ${m.role === "user" ? "bg-brand-accent text-white" : "bg-badge-bg text-brand-ink"}`}
                >
                  {m.parts.map((part, i) => {
                    if (part.type !== "text") {
                      return null;
                    }
                    // Index is a stable key here: streamed message parts are append-only and never reorder.
                    const key = `${m.id}-${i}`;
                    if (m.role === "user") {
                      return <span key={key}>{part.text}</span>;
                    }
                    return (
                      <div className="chat-markdown" key={key}>
                        <Markdown>{part.text}</Markdown>
                      </div>
                    );
                  })}
                </div>
              </div>
            ))}
            {status === "submitted" && <div className="text-base text-zinc-500">Thinking…</div>}
            {error && <div className="rounded-lg bg-red-50 px-3 py-2 text-base text-red-600">{error.message}</div>}
          </div>
          <form className="border-border-soft border-t p-3" onSubmit={handleSubmit}>
            <input
              className="w-full rounded-lg border border-border-soft bg-white px-3 py-2 text-base text-brand-ink outline-none transition placeholder:text-zinc-400 focus:border-brand-accent focus:ring-2 focus:ring-brand-spark"
              disabled={status !== "ready"}
              onChange={(e) => setInputValue(e.target.value)}
              placeholder="Ask something…"
              value={inputValue}
            />
          </form>
        </div>
      ) : (
        <button
          className="flex items-center gap-2 rounded-lg bg-brand-ink px-4 py-3 font-semibold text-sm text-white shadow-xl transition-colors hover:bg-brand-accent"
          onClick={() => setIsOpen(true)}
          type="button"
        >
          <MessageCircle className="h-4 w-4 text-brand-spark" /> Ask AI
        </button>
      )}
    </div>
  );
}
