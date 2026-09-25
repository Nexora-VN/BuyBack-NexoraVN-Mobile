import {
  BeVietnamPro_400Regular,
  BeVietnamPro_500Medium,
  BeVietnamPro_600SemiBold,
  BeVietnamPro_700Bold,
  BeVietnamPro_900Black,
  useFonts,
} from "@expo-google-fonts/be-vietnam-pro";
import { Redirect, Slot, useSegments } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { useEffect, useState } from "react";
import { ActivityIndicator, View } from "react-native";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { ToastProvider } from "../src/components/patterns/Toast";
import { colors } from "../src/constants/colors";
import { restoreLocale } from "../src/i18n/config"; // also initializes i18next
import { AuthProvider, useAuth } from "../src/providers/auth-provider";
import { AppQueryProvider } from "../src/providers/query-provider";

function Splash() {
  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center", backgroundColor: colors.background }}>
      <ActivityIndicator color={colors.primary} />
    </View>
  );
}

function AuthGate() {
  const { user, loading } = useAuth();
  const segments = useSegments();
  const inAuthGroup = segments[0] === "(auth)";

  if (loading) return <Splash />;
  if (!user && !inAuthGroup) return <Redirect href="/login" />;
  if (user && inAuthGroup) return <Redirect href="/" />;
  return <Slot />;
}

export default function RootLayout() {
  const [fontsLoaded, fontError] = useFonts({
    BeVietnamPro_400Regular,
    BeVietnamPro_500Medium,
    BeVietnamPro_600SemiBold,
    BeVietnamPro_700Bold,
    BeVietnamPro_900Black,
  });
  const [localeReady, setLocaleReady] = useState(false);
  useEffect(() => {
    void restoreLocale().finally(() => setLocaleReady(true));
  }, []);

  return (
    <SafeAreaProvider>
      <StatusBar style="dark" />
      {(!fontsLoaded && !fontError) || !localeReady ? (
        <Splash />
      ) : (
        <AppQueryProvider>
          <ToastProvider>
            <AuthProvider>
              <AuthGate />
            </AuthProvider>
          </ToastProvider>
        </AppQueryProvider>
      )}
    </SafeAreaProvider>
  );
}
