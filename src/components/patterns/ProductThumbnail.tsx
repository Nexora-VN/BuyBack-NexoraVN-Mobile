import { ImageOff } from "lucide-react-native";
import { useState } from "react";
import { Image, StyleSheet, View } from "react-native";
import { colors, extra } from "../../constants/colors";
import { useCopy } from "../../i18n/use-copy";

/** web `ProductThumbnail`: bg-muted rounded-xl border border-border/50, ImageOff fallback. */
export function ProductThumbnail({ src, name, size = 48 }: { src?: string | null; name: string; size?: number }) {
  return <Thumbnail key={src ?? ""} src={src} name={name} size={size} />;
}

function Thumbnail({ src, name, size }: { src?: string | null; name: string; size: number }) {
  const t = useCopy();
  const [failed, setFailed] = useState(false);
  return (
    <View style={[styles.box, { width: size, height: size, borderRadius: Math.min(24, size / 2) }]}>
      {src && !failed ? (
        <Image
          source={{ uri: src }}
          accessibilityLabel={name}
          resizeMode="cover"
          style={styles.image}
          onError={() => setFailed(true)}
        />
      ) : (
        <ImageOff color={extra.mutedFg60} size={20} accessibilityLabel={t("Chưa có ảnh sản phẩm")} />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  box: {
    backgroundColor: colors.muted,
    borderWidth: 1,
    borderColor: colors.border,
    alignItems: "center",
    justifyContent: "center",
    overflow: "hidden",
    flexShrink: 0,
  },
  image: { width: "100%", height: "100%" },
});
