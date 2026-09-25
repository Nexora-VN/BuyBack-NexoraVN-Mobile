import { forwardRef, useState } from "react";
import { Pressable, StyleSheet, Text, TextInput, View, type TextInputProps } from "react-native";
import Svg, { Polyline } from "react-native-svg";
import { colors, extra, font, radii } from "../../constants/colors";
import { Sheet } from "../patterns/Sheet";

export interface InputProps extends TextInputProps {
  invalid?: boolean;
}

/** web `Input`: h-11 rounded-xl border bg-white px-3 text-base, focus ring-2 ring/15. */
export const Input = forwardRef<TextInput, InputProps>(function Input(
  { style, invalid, onFocus, onBlur, editable, ...props },
  ref,
) {
  const [focused, setFocused] = useState(false);
  return (
    <TextInput
      ref={ref}
      editable={editable}
      placeholderTextColor={extra.mutedFg70}
      onFocus={(e) => {
        setFocused(true);
        onFocus?.(e);
      }}
      onBlur={(e) => {
        setFocused(false);
        onBlur?.(e);
      }}
      aria-invalid={invalid}
      style={[
        styles.input,
        focused && styles.focused,
        editable === false && styles.disabled,
        style,
      ]}
      {...props}
    />
  );
});

export interface SelectOption {
  value: string;
  label: string;
}

/** web `Select` (native <select>): closed state styled like Input; options open in a sheet. */
export function Select({
  value,
  options,
  onChange,
  title,
  invalid,
}: {
  value: string;
  options: SelectOption[];
  onChange: (value: string) => void;
  title: string;
  invalid?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const current = options.find((o) => o.value === value) ?? options[0];
  return (
    <>
      <Pressable
        accessibilityRole="combobox"
        aria-invalid={invalid}
        onPress={() => setOpen(true)}
        style={[styles.input, styles.select, open && styles.focused]}
      >
        <Text numberOfLines={1} style={styles.selectText}>
          {current?.label ?? ""}
        </Text>
        {/* Chrome's native <select> arrow: 9×5.5 heavy chevron, 4.5px from the outer edge. */}
        <Svg width={10} height={7} viewBox="0 0 10 7">
          <Polyline points="1,1 5,5.5 9,1" fill="none" stroke={colors.foreground} strokeWidth={2.4} />
        </Svg>
      </Pressable>
      <Sheet compact open={open} onOpenChange={setOpen} title={title}>
        <View style={styles.options}>
          {options.map((o) => {
            const active = o.value === value;
            return (
              <Pressable
                key={o.value}
                accessibilityRole="menuitem"
                onPress={() => {
                  onChange(o.value);
                  setOpen(false);
                }}
                style={({ pressed }) => [styles.option, (active || pressed) && styles.optionActive]}
              >
                <Text style={[styles.optionText, active && styles.optionTextActive]}>{o.label}</Text>
              </Pressable>
            );
          })}
        </View>
      </Sheet>
    </>
  );
}

const styles = StyleSheet.create({
  input: {
    height: 44,
    width: "100%",
    borderRadius: radii.xl,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: "#ffffff",
    paddingHorizontal: 12,
    ...font(16),
    color: colors.foreground,
  },
  // focus:border-ring loses to the web's unlayered `* { border-color }` rule. What shows is the
  // ring-2 shadow plus globals.css `:focus-visible { outline: 2px solid var(--ring); outline-offset: 2px }`.
  focused: {
    boxShadow: `0 0 0 2px ${extra.ring15}`,
    outlineWidth: 2,
    outlineStyle: "solid",
    outlineColor: colors.ring,
    outlineOffset: 2,
  },
  disabled: { backgroundColor: colors.muted, opacity: 0.7 },
  select: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 8, paddingRight: 3 },
  // Chrome insets <select> text ~4px beyond the box padding.
  selectText: { ...font(16), color: colors.foreground, flexShrink: 1, marginLeft: 4 },
  options: { gap: 4 },
  option: { minHeight: 44, justifyContent: "center", paddingHorizontal: 12, borderRadius: radii.lg },
  optionActive: { backgroundColor: colors.secondary },
  optionText: { ...font(16), color: colors.foreground },
  optionTextActive: { color: colors.primary, ...font(16, 500) },
});
