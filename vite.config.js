import vue from "@vitejs/plugin-vue";
import laravel from "laravel-vite-plugin";
import { defineConfig, loadEnv } from "vite";

export default defineConfig(({ mode }) => {
    // ✅ Load environment variables from .env file
    const env = loadEnv(mode, process.cwd(), "");

    return {
        plugins: [
            laravel({
                input: [
                    "resources/js/app.js",
                    "resources/js/install.js",
                ],
                refresh: true,
            }),
            vue({
                template: {
                    transformAssetUrls: {
                        base: null,
                        includeAbsolute: false,
                    },
                },
            }),
        ],

        // ✅ Make sure env vars (VITE_) are available in build
        define: {
            __APP_ENV__: env.APP_ENV,
            "process.env": env,
        },

        // ✅ Build optimization (important for Render)
        build: {
            chunkSizeWarningLimit: 1500,
        },

        // ✅ Allow correct network & dev server config
        server: {
            host: "0.0.0.0",
            port: 5173,
            strictPort: true,
        },
    };
});
