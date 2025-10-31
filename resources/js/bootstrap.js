import axios from "axios";
window.axios = axios;

// Default Laravel Axios config
window.axios.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest";

/**
 * ✅ Pusher + Laravel Echo Setup (tested on Render + Laravel 11 + Vite 5)
 */
import Echo from "laravel-echo";
import Pusher from "pusher-js";

// Make available globally
window.Pusher = Pusher;

// Debug logs for testing (optional)
console.log("🟢 VITE_PUSHER_APP_KEY:", import.meta.env.VITE_PUSHER_APP_KEY);
console.log("🟢 VITE_PUSHER_HOST:", import.meta.env.VITE_PUSHER_HOST);
console.log("🟢 VITE_PUSHER_CLUSTER:", import.meta.env.VITE_PUSHER_APP_CLUSTER);
console.log("🟢 VITE_PUSHER_SCHEME:", import.meta.env.VITE_PUSHER_SCHEME);

window.Echo = new Echo({
    broadcaster: "pusher",
    key: import.meta.env.VITE_PUSHER_APP_KEY,
    cluster: import.meta.env.VITE_PUSHER_APP_CLUSTER ?? "ap2",
    wsHost:
        import.meta.env.VITE_PUSHER_HOST?.replace(/^https?:\/\//, "") ||
        `ws-${import.meta.env.VITE_PUSHER_APP_CLUSTER}.pusher.com`,
    wsPort: Number(import.meta.env.VITE_PUSHER_PORT ?? 443),
    wssPort: Number(import.meta.env.VITE_PUSHER_PORT ?? 443),
    forceTLS: (import.meta.env.VITE_PUSHER_SCHEME ?? "https") === "https",
    enabledTransports: ["ws", "wss"],
    disableStats: true,
});
