/* eslint-disable import/order */
import '../css/app.css';
import './bootstrap';

import { createApp, h } from 'vue';

import { createInertiaApp } from '@inertiajs/vue3';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import "tippy.js/dist/tippy.css";
import "tippy.js/themes/light.css";
import "v-calendar/dist/style.css";
import { createI18n } from "vue-i18n";
import VueTippy from "vue-tippy";
import { ZiggyVue } from 'ziggy-js';
import "../css/vcalendar-theme.css";
import messages from "./vue-i18n-locales.generated.js";

const appName = import.meta.env.VITE_APP_NAME || 'Laravel';
createInertiaApp({
    title: (title) => `${title} - ${appName}`,
    resolve: (name) =>
        resolvePageComponent(
            `./Pages/${name}.vue`,
            import.meta.glob('./Pages/**/*.vue'),
        ),
    setup({ el, App, props, plugin }) {
        const i18n = createI18n({
            locale: props.initialPage.props.locale,
            fallbackLocale: "en", // set fallback locale
            messages, // set locale messages,
            legacy: false,
        });

        const app = createApp({ render: () => h(App, props) })
            .use(plugin)
            .use(ZiggyVue)
            .use(i18n)
            .use(VueTippy)
            .mount(el);
        return app;
    },
    progress: {
        color: '#f5f5f3',
    },
});
