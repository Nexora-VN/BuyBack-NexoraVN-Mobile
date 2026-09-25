import { Stack } from "expo-router";
import { View } from "react-native";
import { AppHeader } from "../../src/components/patterns/AppHeader";
import { BottomNav } from "../../src/components/patterns/BottomNav";
import { ChromeProvider } from "../../src/components/patterns/chrome";
import { ConfirmProvider } from "../../src/components/patterns/ConfirmProvider";
import { colors } from "../../src/constants/colors";

/** Port of web `UserShell`: sticky header, page content, fixed 4-column bottom navigation. */
export default function AppLayout() {
  return (
    <ChromeProvider>
      <ConfirmProvider>
        <View style={{ flex: 1, backgroundColor: colors.background }}>
          <AppHeader />
          <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: colors.background } }} />
          <BottomNav />
        </View>
      </ConfirmProvider>
    </ChromeProvider>
  );
}
