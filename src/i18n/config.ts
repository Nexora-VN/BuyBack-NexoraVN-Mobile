import i18n from "i18next";
import * as SecureStore from "expo-secure-store";
import { Platform } from "react-native";
import { initReactI18next } from "react-i18next";
import en from "../../translations/en.json";
import vi from "../../translations/vi.json";
import { defaultLocale, isLocale, type Locale } from "../constants/languages";

const LOCALE_KEY = "buyback_locale";

if (!i18n.isInitialized) {
  i18n.use(initReactI18next).init({
    resources: {
      vi: { UI: vi.UI, Language: vi.Language },
      en: { UI: en.UI, Language: en.Language },
    },
    lng: defaultLocale,
    fallbackLng: defaultLocale,
    defaultNS: "UI",
    interpolation: { escapeValue: false, prefix: "{", suffix: "}" },
  });
}

// The web keeps the locale in the URL (/en prefix); on mobile it is a persisted preference.
async function readLocale(): Promise<string | null> {
  try {
    if (Platform.OS === "web") return globalThis.localStorage?.getItem(LOCALE_KEY) ?? null;
    return await SecureStore.getItemAsync(LOCALE_KEY);
  } catch {
    return null;
  }
}

export async function setLocale(locale: Locale): Promise<void> {
  await i18n.changeLanguage(locale);
  try {
    if (Platform.OS === "web") globalThis.localStorage?.setItem(LOCALE_KEY, locale);
    else await SecureStore.setItemAsync(LOCALE_KEY, locale);
  } catch {
    // Preference persistence is best-effort.
  }
}

export async function restoreLocale(): Promise<void> {
  const saved = await readLocale();
  if (saved && isLocale(saved) && saved !== i18n.language) await i18n.changeLanguage(saved);
}

export default i18n;
