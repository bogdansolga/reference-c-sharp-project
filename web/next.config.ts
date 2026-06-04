import type { NextConfig } from "next";

// The C# API (ASP.NET Core) base URL. /api/v1/* and /api/auth/* are proxied here;
// /api/chat stays local to Next (Anthropic via the Vercel AI SDK).
const API_URL = process.env.API_URL || "http://localhost:5099";

const nextConfig: NextConfig = {
  typescript: {
    ignoreBuildErrors: false,
  },

  reactStrictMode: true,

  async rewrites() {
    return [
      { source: "/api/v1/:path*", destination: `${API_URL}/api/v1/:path*` },
      { source: "/api/auth/:path*", destination: `${API_URL}/api/auth/:path*` },
    ];
  },

  experimental: {
    webpackBuildWorker: true,
    cpus: Math.max(1, Math.floor(require("node:os").cpus().length * 0.8)),
    memoryBasedWorkersCount: true,
    optimizeServerReact: true,
    turbopackMemoryLimit: 1024 * 1024 * 1024 * 2,
    turbopackSourceMaps: true,
    browserDebugInfoInTerminal: true,
    turbopackFileSystemCacheForDev: true,
  },
};

export default nextConfig;
