export const useAppConfigSiteUrl = () => {
	const config = useRuntimeConfig();

	const getBaseUrl = () => {
		return config.public.baseUrl;
	};

	const getSiteUrl = () => {
		return config.public.siteUrl;
	};

	const getAuthRedirectUrl = (path: string = "") => {
		const baseUrl = getSiteUrl();
		return `${baseUrl}${path}`;
	};

	return {
		getBaseUrl,
		getSiteUrl,
		getAuthRedirectUrl,
	};
};
