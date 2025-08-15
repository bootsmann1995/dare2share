// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
	compatibilityDate: "2025-07-15",
	devtools: { enabled: true },

	modules: ["@nuxtjs/supabase", "@nuxtjs/tailwindcss"],

	supabase: {
		redirectOptions: {
			login: "/auth/login",
			callback: "/auth/callback",
			exclude: ["/", "/auth/login", "/auth/register"],
		},
		url: process.env.SUPABASE_URL,
		key: process.env.SUPABASE_ANON_KEY,
	},

	runtimeConfig: {
		public: {
			supabaseUrl: process.env.SUPABASE_URL,
			supabaseAnonKey: process.env.SUPABASE_ANON_KEY,
		},
	},
});
