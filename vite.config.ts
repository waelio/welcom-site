import { defineConfig } from "vite";

export default defineConfig({
    appType: "mpa",
    server: {
        host: "127.0.0.1",
        port: 4173,
        strictPort: true,
        open: "/index.html",
    },
    preview: {
        host: "127.0.0.1",
        port: 4173,
        strictPort: true,
        open: "/index.html",
    },
});
