import { Globe2 } from "lucide-react-native";
import { useTranslation } from "react-i18next";
import { StyleSheet, View } from "react-native";
import { colors } from "../../constants/colors";
import { languages, type Locale } from "../../constants/languages";
import { setLocale } from "../../i18n/config";
import { Button } from "../ui/Button";

/** Port of web `LanguageSwitcher`: bordered bg-background group, active locale as a default-variant sm button. */
export function LanguageSwitcher({ grow = false }: { grow?: boolean }) {
  const { i18n, t } = useTranslation("Language");
  const active = (i18n.language === "en" ? "en" : "vi") as Locale;
  return (
    <View accessibilityLabel={t("label")} style={[styles.group, !grow && styles.inline]}>
      <Globe2 color={colors.mutedForeground} size={16} style={styles.icon} />
      {languages.map((language) => {
        const current = language.locale === active;
        return (
          <Button
            key={language.locale}
            size="sm"
            variant={current ? "default" : "ghost"}
            label={language.shortLabel}
            accessibilityLabel={language.label}
            accessibilityState={{ selected: current }}
            onPress={() => void setLocale(language.locale)}
          />
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  group: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.background,
    borderRadius: 16,
    padding: 4,
  },
  inline: { alignSelf: "flex-start" },
  icon: { marginHorizontal: 4 },
});
