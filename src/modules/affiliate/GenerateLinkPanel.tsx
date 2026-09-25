import { useQueryClient } from "@tanstack/react-query";
import * as Clipboard from "expo-clipboard";
import { Check, Copy, ExternalLink, ImageOff, Link2, ShoppingCart } from "lucide-react-native";
import { useRef, useState } from "react";
import { Image, Linking, StyleSheet, Text, View } from "react-native";
import { ApiErrorNotice } from "../../components/patterns/QueryState";
import { useToast } from "../../components/patterns/Toast";
import { Button } from "../../components/ui/Button";
import { Card } from "../../components/ui/Card";
import { Input } from "../../components/ui/Input";
import { colors, font } from "../../constants/colors";
import { useCopy } from "../../i18n/use-copy";
import { apiClient } from "../../lib/api/client";
import { formatVnd } from "../../lib/format";
import type { GenerateAffiliateResponse } from "./types";

const shopeeHosts = ["shopee.vn", "s.shopee.vn", "vn.shp.ee", "shp.ee", "shope.ee", "www.shopee.vn"];

/** Port of web `useGenerateLink`. */
function useGenerateLink() {
  const t = useCopy();
  const toast = useToast();
  const [url, setUrl] = useState("");
  const [result, setResult] = useState<GenerateAffiliateResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [imageFailed, setImageFailed] = useState(false);
  const [requestError, setRequestError] = useState<unknown>(null);
  const revision = useRef(0);
  const pending = useRef(false);
  const queryClient = useQueryClient();

  async function generate() {
    if (pending.current) return;
    setResult(null);
    setRequestError(null);
    const input = url.trim();
    try {
      const parsed = new URL(input);
      if (
        !shopeeHosts.includes(parsed.hostname) ||
        parsed.username ||
        parsed.password ||
        (parsed.port && parsed.port !== "443") ||
        parsed.protocol !== "https:"
      ) {
        toast.error(t.error("Chỉ hỗ trợ link Shopee hợp lệ"));
        return;
      }
    } catch {
      toast.error(t.error("Link không hợp lệ"));
      return;
    }
    const requestRevision = revision.current;
    pending.current = true;
    setLoading(true);
    try {
      const response = await apiClient.post<GenerateAffiliateResponse>("generate-affiliate", { url: input });
      // Ignore a response if the user has edited the product URL while it was loading.
      if (requestRevision !== revision.current) return;
      if (!response.link) throw new Error(t("Không tạo được link. Vui lòng thử lại."));
      setImageFailed(false);
      setResult(response);
      void queryClient.invalidateQueries({
        predicate: (query) => query.queryKey[0] === "finance" && String(query.queryKey[1]).includes("links"),
      });
      toast.success(t("Tạo link cashback thành công"));
    } catch (error) {
      if (requestRevision === revision.current) {
        setRequestError(error);
        toast.error(t.error(error instanceof Error ? error.message : t("Tạo link thất bại")));
      }
    } finally {
      pending.current = false;
      setLoading(false);
    }
  }

  async function copy() {
    if (!result?.link) return;
    try {
      await Clipboard.setStringAsync(result.link);
      toast.success(t("Đã sao chép link chia sẻ"));
    } catch {
      toast.error(t.error("Không thể sao chép link. Vui lòng thử lại."));
    }
  }

  const changeUrl = (value: string) => {
    revision.current += 1;
    setUrl(value);
    setResult(null);
    setRequestError(null);
  };
  return { t, url, result, loading, imageFailed, setImageFailed, generate, copy, changeUrl, requestError, product: result?.product };
}

function formatAmount(value: string | null | undefined) {
  return value != null && /^\d+$/.test(value) ? formatVnd(value) : null;
}

/** Port of web `GenerateLinkPanel` (form + result card + notes card, stacked at mobile width). */
export function GenerateLinkPanel() {
  const state = useGenerateLink();
  const { t, url, loading, changeUrl, generate, result, product, imageFailed, setImageFailed, copy } = state;
  return (
    <View style={styles.panel}>
      <Card>
        <View style={styles.iconBox}>
          <Link2 color={colors.primary} size={24} />
        </View>
        <Text style={styles.label}>{t("Link sản phẩm Shopee, TikTok")}</Text>
        <View style={styles.formRow}>
          <Input
            value={url}
            onChangeText={changeUrl}
            placeholder={t("Dán link sản phẩm vào đây nhé .... ")}
            autoCapitalize="none"
            autoCorrect={false}
            keyboardType="url"
            onSubmitEditing={() => void generate()}
          />
          <Button
            size="lg"
            icon={Link2}
            loading={loading}
            disabled={loading || !url.trim()}
            label={loading ? t("Đang tạo…") : t("Mua sắm ngay")}
            onPress={() => void generate()}
          />
        </View>
        <ApiErrorNotice error={state.requestError} />
        {result?.link ? (
          <View accessibilityLabel={t("Kết quả tạo link")} accessibilityLiveRegion="polite" style={styles.result}>
            <View style={styles.resultHead}>
              <Check color={colors.success} size={20} />
              <Text style={styles.resultHeadText}>{t("Piggy mang tới tin tốt cho bạn")}</Text>
            </View>
            <View style={styles.productRow}>
              <View style={styles.productImage}>
                {product?.imageUrl && !imageFailed ? (
                  <Image
                    source={{ uri: product.imageUrl }}
                    accessibilityLabel={product.productName}
                    resizeMode="contain"
                    style={styles.fill}
                    onError={() => setImageFailed(true)}
                  />
                ) : (
                  <ImageOff color={colors.mutedForeground} size={32} accessibilityLabel={t("Chưa có ảnh sản phẩm")} />
                )}
              </View>
              <View style={styles.productInfo}>
                <Text style={styles.productName}>{product?.productName || t("Sản phẩm Shopee")}</Text>
                {product?.shopName ? <Text style={styles.shopName}>{product.shopName}</Text> : null}
                <Text style={styles.price}>{formatAmount(product?.price) ?? t("Chưa có thông tin giá")}</Text>
              </View>
            </View>
            <View style={styles.commissionBox}>
              <Text style={styles.commissionLabel}>{t("Số tiền được hoàn lại lên tới")}</Text>
              {/* Uses the provider commission directly, as the web does. */}
              <Text style={styles.commission}>{formatAmount(product?.commission) ?? t("Chưa có thông tin hoa hồng")}</Text>
              <Text style={styles.commissionNote}>
                {t("Lưu ý nhỏ nhỏ: Đây là tham khảo, con số chính xác sẽ có sau khi Shopee, TikTok xác nhận nhé..")}
              </Text>
            </View>
            <View style={styles.resultActions}>
              <Button size="lg" icon={ExternalLink} label={t("Mua ngay")} onPress={() => void Linking.openURL(result.link!)} />
              <Button
                variant="outline"
                size="lg"
                icon={Copy}
                wrap
                label={t("Copy link chia sẻ cho bạn bè")}
                onPress={() => void copy()}
                style={styles.copyButton}
              />
            </View>
          </View>
        ) : null}
      </Card>
      <GenerateLinkNotes />
    </View>
  );
}

function GenerateLinkNotes() {
  const t = useCopy();
  const items = [
    t("Nếu sản phẩm có trong giỏ hàng, bạn nhớ xóa ra khỏi giỏ nhe"),
    t("Nhấn “Mua ngay” trên trang này."),
    t("Thêm lại sản phẩm và tiến hành đặt hàng."),
    t("3 Điều trên giúp bạn hoàn tiền chính xác hơn đó!"),
  ];
  return (
    <Card>
      <View style={styles.notesHead}>
        <View style={styles.notesIcon}>
          <ShoppingCart color={colors.primary} size={24} />
        </View>
        <Text style={styles.notesTitle}>{t("Vài lưu ý Piggy gửi tới bạn")}</Text>
      </View>
      <View style={styles.notesList}>
        {items.map((item, index) => (
          <View key={item} style={styles.noteItem}>
            <View style={styles.noteNumber}>
              <Text style={styles.noteNumberText}>{index + 1}</Text>
            </View>
            <Text style={styles.noteText}>{item}</Text>
          </View>
        ))}
      </View>
      <Text style={styles.notesFooter}>
        {t(
          "Đây là các bước giúp bạn thuận lợi hơn trong việc được hoàn tiền nè. Tuy nhiên vẫn sẽ dựa vào trạng thái đơn hàng Shopee, TikTok nếu có dấu hiệu gian lận đó nhen.",
        )}
      </Text>
    </Card>
  );
}

const styles = StyleSheet.create({
  panel: { gap: 20 },
  iconBox: {
    width: 48,
    height: 48,
    borderRadius: 16,
    backgroundColor: colors.secondary,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 20,
  },
  // Inline <label> in a block: the parent's 24px line box; the 14px text sits 1px below centre.
  label: { ...font(14, 600, 23), paddingTop: 1, color: colors.foreground },
  formRow: { marginTop: 8, gap: 12 },
  result: {
    marginTop: 24,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.successSoft,
    padding: 16,
  },
  resultHead: { flexDirection: "row", alignItems: "center", gap: 8, marginBottom: 16 },
  resultHeadText: { ...font(14, 600), color: colors.success },
  productRow: { flexDirection: "row", alignItems: "flex-start", gap: 16 },
  productImage: {
    width: 96,
    height: 96,
    borderRadius: 24,
    backgroundColor: "#ffffff",
    overflow: "hidden",
    alignItems: "center",
    justifyContent: "center",
  },
  fill: { width: "100%", height: "100%" },
  productInfo: { flex: 1, minWidth: 0 },
  productName: { ...font(16, 600), color: colors.foreground },
  shopName: { ...font(14), color: colors.mutedForeground, marginTop: 4 },
  price: { ...font(16, 600), color: colors.foreground, marginTop: 8 },
  commissionBox: { marginVertical: 20, borderRadius: 24, backgroundColor: "#ffffff", padding: 16 },
  commissionLabel: { ...font(14, 500), color: colors.foreground },
  commission: { ...font(36, 700), color: colors.primary, marginTop: 4 },
  commissionNote: { ...font(12, 400, 20), color: colors.mutedForeground, marginTop: 8 },
  resultActions: { gap: 12 },
  copyButton: { height: "auto", minHeight: 44 },
  notesHead: { flexDirection: "row", alignItems: "center", gap: 12 },
  notesIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: colors.secondary,
    alignItems: "center",
    justifyContent: "center",
  },
  notesTitle: { ...font(16, 600), color: colors.foreground, flexShrink: 1 },
  notesList: { marginTop: 20, gap: 16 },
  noteItem: { flexDirection: "row", gap: 12 },
  noteNumber: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: colors.secondary,
    alignItems: "center",
    justifyContent: "center",
  },
  noteNumberText: { ...font(12, 700), color: colors.primary },
  noteText: { ...font(14, 400, 24), color: colors.mutedForeground, flex: 1 },
  notesFooter: {
    marginTop: 24,
    borderRadius: 24,
    backgroundColor: colors.muted,
    padding: 12,
    ...font(12, 400, 20),
    color: colors.mutedForeground,
    overflow: "hidden",
  },
});
