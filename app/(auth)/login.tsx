import { zodResolver } from "@hookform/resolvers/zod";
import { Eye, EyeOff, LockKeyhole, Mail } from "lucide-react-native";
import { useState } from "react";
import { Controller, useForm } from "react-hook-form";
import { KeyboardAvoidingView, Platform, Pressable, ScrollView, StyleSheet, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Svg, { Path, Polyline } from "react-native-svg";
import { z } from "zod";
import { LanguageSwitcher } from "../../src/components/patterns/LanguageSwitcher";
import { useToast } from "../../src/components/patterns/Toast";
import { Button } from "../../src/components/ui/Button";
import { Input } from "../../src/components/ui/Input";
import { colors, font } from "../../src/constants/colors";
import { useCopy } from "../../src/i18n/use-copy";
import { ApiError } from "../../src/lib/api/errors";
import { useAuth } from "../../src/providers/auth-provider";

// Same schema as web login-form.tsx.
const schema = z.object({
  email: z.string().email("Email không hợp lệ"),
  password: z.string().min(8, "Mật khẩu phải có ít nhất 8 ký tự"),
  remember: z.boolean(),
});
type FormData = z.infer<typeof schema>;

function GoogleIcon() {
  return (
    // web Button forces child SVGs to 16px (`[&_svg]:size-4`), overriding the icon's own 20px.
    <Svg viewBox="0 0 24 24" width={16} height={16}>
      <Path
        fill="#4285F4"
        d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.82-2.4 3.68v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.17z"
      />
      <Path
        fill="#34A853"
        d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.33 24 12 24z"
      />
      <Path
        fill="#FBBC05"
        d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.14-1.55.38-2.27V6.58H1.25C.45 8.18 0 9.99 0 12s.45 3.82 1.25 5.42l4.03-3.15z"
      />
      <Path
        fill="#EA4335"
        d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.33 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z"
      />
    </Svg>
  );
}

/** Port of web `/login`: brand + language row, Google (Clerk) button, divider, email/password form. */
export default function LoginScreen() {
  const t = useCopy();
  const toast = useToast();
  const insets = useSafeAreaInsets();
  return (
    <KeyboardAvoidingView behavior={Platform.OS === "ios" ? "padding" : undefined} style={styles.main}>
      <ScrollView
        contentContainerStyle={[styles.section, { paddingTop: 24 + insets.top, paddingBottom: 24 + insets.bottom }]}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.topRow}>
          <Text style={styles.brand}>Piggy Buy Back</Text>
          <LanguageSwitcher />
        </View>
        <View style={styles.content}>
          <View style={styles.header}>
            <Text accessibilityRole="header" style={styles.h1}>
              {t("Chào mừng trở lại")}
            </Text>
            <Text style={styles.lead}>{t("Đăng nhập để mua sắm hoàn tiền cùng Piggy nhé")}</Text>
          </View>
          {/*
            Google sign-in on the web goes through Clerk and then the Next.js BFF route /api/auth/clerk-sync,
            which calls POST /auth/clerk with the server-only X-Clerk-Sync-Secret. A mobile binary cannot hold
            that secret, so this path is blocked until the backend accepts a verifiable Clerk session token.
            The button keeps the web layout and reports the web's own auth-service failure message.
          */}
          <Pressable
            accessibilityRole="button"
            onPress={() => toast.error(t("Không thể kết nối với dịch vụ xác thực"))}
            style={({ pressed }) => [styles.google, pressed && styles.googlePressed]}
          >
            <GoogleIcon />
            <Text style={styles.googleText}>{t("Đăng nhập với Google")}</Text>
          </Pressable>
          <View style={styles.divider}>
            <View style={styles.dividerLine} />
            <Text style={styles.dividerText}>{t("hoặc tiếp tục với tài khoản hệ thống").toUpperCase()}</Text>
            <View style={styles.dividerLine} />
          </View>
          <LoginForm />
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

function LoginForm() {
  const t = useCopy();
  const toast = useToast();
  const { login } = useAuth();
  const [submitError, setSubmitError] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const form = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { email: "", password: "", remember: true },
  });
  const errors = form.formState.errors;
  const submit = form.handleSubmit(async (values) => {
    setSubmitError("");
    try {
      await login(values);
      toast.success(t("Đăng nhập thành công"));
      // Navigation is owned by the root AuthGate (redirects once the session exists).
    } catch (error) {
      setSubmitError(error instanceof ApiError ? error.message : "Không thể đăng nhập");
    }
  });
  const submitting = form.formState.isSubmitting;

  return (
    <View style={styles.form}>
      <View>
        <Text style={styles.label}>Email</Text>
        <View>
          <Mail color={colors.mutedForeground} size={16} style={styles.leftIcon} />
          <Controller
            control={form.control}
            name="email"
            render={({ field }) => (
              <Input
                ref={field.ref}
                accessibilityLabel="Email"
                value={field.value}
                onChangeText={field.onChange}
                onBlur={field.onBlur}
                invalid={!!errors.email}
                keyboardType="email-address"
                autoCapitalize="none"
                autoComplete="email"
                textContentType="emailAddress"
                placeholder="you@example.com"
                style={styles.withLeftIcon}
              />
            )}
          />
        </View>
        {errors.email ? (
          <Text accessibilityRole="alert" style={styles.fieldError}>
            {t(errors.email.message ?? "")}
          </Text>
        ) : null}
      </View>
      <View>
        <Text style={styles.label}>{t("Mật khẩu")}</Text>
        <View>
          <LockKeyhole color={colors.mutedForeground} size={16} style={styles.leftIcon} />
          <Controller
            control={form.control}
            name="password"
            render={({ field }) => (
              <Input
                ref={field.ref}
                accessibilityLabel={t("Mật khẩu")}
                value={field.value}
                onChangeText={field.onChange}
                onBlur={field.onBlur}
                invalid={!!errors.password}
                secureTextEntry={!showPassword}
                autoComplete="current-password"
                textContentType="password"
                style={styles.withBothIcons}
                onSubmitEditing={() => void submit()}
              />
            )}
          />
          <Pressable
            accessibilityRole="button"
            accessibilityLabel={showPassword ? t("Ẩn mật khẩu") : t("Hiện mật khẩu")}
            onPress={() => setShowPassword((v) => !v)}
            style={({ pressed }) => [styles.eye, pressed && { backgroundColor: colors.muted }]}
          >
            {showPassword ? (
              <EyeOff color={colors.mutedForeground} size={16} />
            ) : (
              <Eye color={colors.mutedForeground} size={16} />
            )}
          </Pressable>
        </View>
        {errors.password ? (
          <Text accessibilityRole="alert" style={styles.fieldError}>
            {t(errors.password.message ?? "")}
          </Text>
        ) : null}
      </View>
      <Controller
        control={form.control}
        name="remember"
        render={({ field }) => (
          <Pressable
            accessibilityRole="checkbox"
            accessibilityState={{ checked: field.value }}
            onPress={() => field.onChange(!field.value)}
            style={styles.remember}
          >
            <View style={[styles.checkbox, field.value && styles.checkboxOn]}>
              {/* Chrome's native checked mark (accent-color: primary): heavy square-ended tick */}
              {field.value ? (
                <Svg width={18} height={18} viewBox="0 0 18 18">
                  <Polyline points="2.8,9.6 7,13.4 15.4,3.4" fill="none" stroke="#ffffff" strokeWidth={3} />
                </Svg>
              ) : null}
            </View>
            <Text style={styles.rememberText}>{t("Duy trì đăng nhập trên thiết bị này")}</Text>
          </Pressable>
        )}
      />
      {submitError ? (
        <Text accessibilityRole="alert" style={styles.submitError}>
          {t.error(submitError)}
        </Text>
      ) : null}
      <Button
        size="lg"
        disabled={submitting}
        loading={submitting}
        label={submitting ? t("Đang đăng nhập") : t("Đăng nhập")}
        onPress={() => void submit()}
        style={styles.fullWidth}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  main: { flex: 1, backgroundColor: colors.card },
  section: { flexGrow: 1, paddingHorizontal: 20 },
  topRow: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 16 },
  brand: { ...font(16, 600), color: colors.primary },
  content: { flex: 1, justifyContent: "center", paddingVertical: 40, width: "100%", maxWidth: 448, alignSelf: "center" },
  header: { marginBottom: 28 },
  h1: { ...font(24, 700), color: colors.foreground },
  lead: { ...font(14, 400, 24), color: colors.mutedForeground, marginTop: 10 },
  google: {
    height: 48,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 12,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.card,
    borderRadius: 24,
    paddingHorizontal: 24,
    paddingVertical: 10,
  },
  googlePressed: { backgroundColor: colors.muted },
  googleText: { ...font(16, 500), color: colors.foreground },
  divider: { flexDirection: "row", alignItems: "center", marginVertical: 24 },
  dividerLine: { flex: 1, height: 1, backgroundColor: colors.border },
  dividerText: { ...font(12, 500), color: colors.mutedForeground, paddingHorizontal: 12, textAlign: "center" },
  form: { gap: 20 },
  label: { ...font(14, 500), color: colors.foreground, marginBottom: 8 },
  leftIcon: { position: "absolute", top: 14, left: 12, zIndex: 1, pointerEvents: "none" },
  withLeftIcon: { paddingLeft: 40 },
  withBothIcons: { paddingLeft: 40, paddingRight: 40 },
  eye: {
    position: "absolute",
    top: 0,
    right: 0,
    width: 44,
    height: 44,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
  },
  fieldError: { ...font(12), color: colors.danger, marginTop: 6 },
  remember: { flexDirection: "row", alignItems: "center", gap: 8 },
  checkbox: {
    width: 20,
    height: 20,
    borderRadius: 3,
    borderWidth: 1,
    borderColor: "#767676",
    backgroundColor: "#ffffff",
    alignItems: "center",
    justifyContent: "center",
  },
  checkboxOn: { backgroundColor: colors.primary, borderColor: colors.primary },
  rememberText: { ...font(14), color: colors.mutedForeground, flexShrink: 1 },
  submitError: { ...font(14), color: colors.danger },
  fullWidth: { width: "100%" },
});
