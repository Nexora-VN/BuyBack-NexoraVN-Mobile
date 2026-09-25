import * as SecureStore from "expo-secure-store";
import { Platform } from "react-native";

const ACCESS_TOKEN_KEY = "buyback_access_token";
const REFRESH_TOKEN_KEY = "buyback_refresh_token";

// expo-secure-store has no web implementation. localStorage isn't as
// secure as the OS keychain, but it's the standard fallback for the
// web preview target — native iOS/Android always use SecureStore.
const isWeb = Platform.OS === "web";

// "Duy trì đăng nhập" unchecked → web uses session cookies; mobile keeps tokens in memory only.
const memory = new Map<string, string>();

async function getItem(key: string): Promise<string | null> {
  if (memory.has(key)) return memory.get(key)!;
  if (isWeb) return globalThis.localStorage?.getItem(key) ?? null;
  return SecureStore.getItemAsync(key);
}

async function setItem(key: string, value: string): Promise<void> {
  if (isWeb) {
    globalThis.localStorage?.setItem(key, value);
    return;
  }
  await SecureStore.setItemAsync(key, value);
}

async function deleteItem(key: string): Promise<void> {
  memory.delete(key);
  if (isWeb) {
    globalThis.localStorage?.removeItem(key);
    return;
  }
  await SecureStore.deleteItemAsync(key);
}

export async function getAccessToken(): Promise<string | null> {
  return getItem(ACCESS_TOKEN_KEY);
}

export async function getRefreshToken(): Promise<string | null> {
  return getItem(REFRESH_TOKEN_KEY);
}

// Refreshes omit `persist` and keep the mode the session started with.
export async function setTokens(
  accessToken: string,
  refreshToken: string,
  persist = !memory.has(ACCESS_TOKEN_KEY),
): Promise<void> {
  if (!persist) {
    await deleteItem(ACCESS_TOKEN_KEY);
    await deleteItem(REFRESH_TOKEN_KEY);
    memory.set(ACCESS_TOKEN_KEY, accessToken);
    memory.set(REFRESH_TOKEN_KEY, refreshToken);
    return;
  }
  memory.clear();
  await setItem(ACCESS_TOKEN_KEY, accessToken);
  await setItem(REFRESH_TOKEN_KEY, refreshToken);
}

export async function clearTokens(): Promise<void> {
  await deleteItem(ACCESS_TOKEN_KEY);
  await deleteItem(REFRESH_TOKEN_KEY);
}
