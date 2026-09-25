import { LinearGradient } from "expo-linear-gradient";
import { useEffect, useState } from "react";
import { Animated, Easing, StyleSheet, View, type DimensionValue } from "react-native";

/**
 * web `.skeleton`: linear-gradient(90deg, #fff0f4 25%, #ffe3ed 50%, #fff0f4 75%) at 200% width,
 * background-position 200% → -200% over 1.4s ease-in-out, infinite.
 */
export function Skeleton({ height, width = "100%", radius }: { height: number; width?: DimensionValue; radius: number }) {
  const [w, setW] = useState(0);
  const [progress] = useState(() => new Animated.Value(0));
  useEffect(() => {
    const loop = Animated.loop(
      Animated.timing(progress, {
        toValue: 1,
        duration: 1400,
        easing: Easing.bezier(0.42, 0, 0.58, 1), // CSS ease-in-out
        useNativeDriver: true,
      }),
    );
    loop.start();
    return () => loop.stop();
  }, [progress]);
  // background-position X% of a 2w-wide repeating layer inside w → offset -(X/100)·w, i.e. -2w → +2w.
  // Three tiles starting at -4w and shifted 0 → 4w reproduce that repeat-tiled motion exactly.
  const translateX = progress.interpolate({ inputRange: [0, 1], outputRange: [0, 4 * w] });
  return (
    <View
      style={[styles.box, { height, width, borderRadius: radius }]}
      onLayout={(e) => setW(e.nativeEvent.layout.width)}
    >
      {w > 0 ? (
        <Animated.View style={[styles.layer, { left: -4 * w, width: w * 6, transform: [{ translateX }] }]}>
          {[0, 1, 2].map((i) => (
            <LinearGradient
              key={i}
              colors={["#fff0f4", "#fff0f4", "#ffe3ed", "#fff0f4", "#fff0f4"]}
              locations={[0, 0.25, 0.5, 0.75, 1]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={{ width: w * 2, height: "100%" }}
            />
          ))}
        </Animated.View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  box: { backgroundColor: "#fff0f4", overflow: "hidden" },
  layer: { position: "absolute", top: 0, bottom: 0, flexDirection: "row" },
});
