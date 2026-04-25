import path from "node:path";
import { defineConfig } from "vite";

export default defineConfig({
    build: {
        emptyOutDir: true,
        lib: {
            entry: path.resolve(__dirname, "src-static/app.ts"),
            fileName: () => "app.js",
            formats: ["es"],
        },
        minify: false,
        outDir: ".generated-static",
        rollupOptions: {
            output: {
                inlineDynamicImports: true,
            },
        },
        sourcemap: false,
        target: "es2020",
    },
});