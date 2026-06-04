"use client";

import { useChat } from "@ai-sdk/react";
import { DefaultChatTransport } from "ai";
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
        <div className="flex h-[28rem] w-lg flex-col rounded-lg border border-zinc-700 bg-zinc-900 text-white shadow-lg">
          <div className="flex items-center justify-between border-zinc-700 border-b p-3">
            <span className="font-medium">Chat</span>
            <button className="text-zinc-400 hover:text-white" onClick={() => setIsOpen(false)}>
              ✕
            </button>
          </div>
          <div className="flex-1 space-y-3 overflow-y-auto p-4">
            {messages.map((m) => (
              <div className={`text-base ${m.role === "user" ? "text-right" : "text-left"}`} key={m.id}>
                <div
                  className={`inline-block max-w-full rounded px-3 py-2 ${m.role === "user" ? "bg-blue-600" : "bg-zinc-700"}`}
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
            {status === "submitted" && <div className="text-base text-zinc-400">Thinking...</div>}
            {error && <div className="rounded bg-red-900/20 px-3 py-2 text-base text-red-400">{error.message}</div>}
          </div>
          <form className="border-zinc-700 border-t p-3" onSubmit={handleSubmit}>
            <input
              className="w-full rounded border border-zinc-600 bg-zinc-800 px-3 py-2 text-base text-white placeholder-zinc-400"
              disabled={status !== "ready"}
              onChange={(e) => setInputValue(e.target.value)}
              placeholder="Ask something..."
              value={inputValue}
            />
          </form>
        </div>
      ) : (
        <button
          className="flex items-center gap-2 rounded-lg bg-zinc-900 px-4 py-3 font-medium text-sm text-white shadow-xl hover:bg-zinc-800"
          onClick={() => setIsOpen(true)}
        >
          <span>💬</span> Ask AI
        </button>
      )}
    </div>
  );
}
