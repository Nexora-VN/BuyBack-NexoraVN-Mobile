import * as Clipboard from "expo-clipboard";
import { router, useLocalSearchParams } from "expo-router";
import {
  ArrowDownToLine,
  Check,
  CircleAlert,
  Clock3,
  Copy,
  ExternalLink,
  ShieldCheck,
  ShoppingBag,
  Wallet,
} from "lucide-react-native";
import { useState } from "react";
import { Linking, Pressable, StyleSheet, Text, View } from "react-native";
import { ProductThumbnail } from "../../../src/components/patterns/ProductThumbnail";
import { Failure, Loading } from "../../../src/components/patterns/QueryState";
import { useToast } from "../../../src/components/patterns/Toast";
import { Card } from "../../../src/components/ui/Card";
import { Page } from "../../../src/components/ui/Page";
import { StatusBadge } from "../../../src/components/ui/StatusBadge";
import { colors, extra, font } from "../../../src/constants/colors";
import { useCopy } from "../../../src/i18n/use-copy";
import { formatDateTime, formatVnd } from "../../../src/lib/format";
import { mono, PlatformChip, read, text } from "../../../src/modules/finance/components/columns";
import { useFinance } from "../../../src/modules/finance/use-finance";
import type { FinanceRow } from "../../../src/types/finance";

function CashbackProgressStepper({
  orderStatus,
  commissionState,
  cashbackState,
  purchasedAt,
}: {
  orderStatus: string;
  commissionState: string;
  cashbackState?: string;
  purchasedAt?: string;
}) {
  const t = useCopy();
  const isCancelled =
    ["REJECTED", "FAILED", "CANCELLED", "cancelled"].includes(orderStatus) ||
    ["REJECTED", "REVERSED"].includes(commissionState) ||
    ["REJECTED", "REVERSED"].includes(cashbackState ?? "");
  const isWithdrawn = ["PAID", "WITHDRAWN"].includes(cashbackState ?? "") || commissionState === "PAID";
  const isAvailable = isWithdrawn || cashbackState === "AVAILABLE";
  const isOrderCompleted = isAvailable || ["VALIDATED", "COMPLETED", "completed", "APPROVED"].includes(orderStatus);

  const steps = [
    { title: t("Đã ghi nhận"), desc: purchasedAt ? formatDateTime(purchasedAt) : t("Ghi nhận qua Piggy"), done: true, current: false },
    {
      title: t("Đơn hoàn tất"),
      desc: isOrderCompleted ? t("Giao thành công") : t("Đang giao hàng"),
      done: isOrderCompleted,
      current: !isOrderCompleted && !isCancelled,
    },
    {
      title: t("Đối soát hoa hồng"),
      desc: isAvailable ? t("Đã đối soát xong") : t("Sàn đang đối soát"),
      done: isAvailable,
      current: isOrderCompleted && !isAvailable && !isCancelled,
    },
    {
      title: isWithdrawn ? t("Đã rút tiền") : t("Tiền vào ví"),
      desc: isWithdrawn ? t("Đã chuyển về ngân hàng") : isAvailable ? t("Sẵn sàng rút tiền") : t("Chờ hoàn tất đối soát"),
      done: isWithdrawn || isAvailable,
      current: isAvailable && !isWithdrawn && !isCancelled,
    },
  ];

  if (isCancelled) {
    return (
      <View style={styles.cancelled}>
        <CircleAlert color={colors.danger} size={20} style={styles.noShrink} />
        <View style={styles.flex1}>
          <Text style={styles.cancelledTitle}>{t("Đơn hàng hoặc hoa hồng không hợp lệ")}</Text>
          <Text style={styles.cancelledText}>
            {t(
              "Đơn hàng này đã bị hủy, đổi trả hoặc không thỏa mãn điều kiện tích lũy của sàn thương mại điện tử.",
            )}
          </Text>
        </View>
      </View>
    );
  }

  const tone = isWithdrawn
    ? { color: colors.info, Icon: ArrowDownToLine, label: t("Đã rút tiền về ngân hàng") }
    : isAvailable
      ? { color: colors.success, Icon: Check, label: t("Sẵn sàng rút tiền") }
      : { color: colors.warning, Icon: Clock3, label: t("Đang trong chu kỳ đối soát") };

  return (
    <Card style={styles.space16}>
      <View style={styles.between}>
        <Text style={styles.overline}>{t("Tiến trình tích lũy hoàn tiền").toUpperCase()}</Text>
        <View style={[styles.inlineIcon, styles.shrink]}>
          <tone.Icon color={tone.color} size={14} style={styles.noShrink} />
          <Text style={[styles.toneText, { color: tone.color }]}>{tone.label}</Text>
        </View>
      </View>
      <View style={styles.stepGrid}>
        {[steps.slice(0, 2), steps.slice(2)].map((pair, row) => (
          <View key={row} style={styles.stepRow}>
            {pair.map((s, i) => {
              const idx = row * 2 + i;
              const infoStep = isWithdrawn && idx === 3;
              const circle = s.done
                ? { backgroundColor: infoStep ? colors.info : colors.success }
                : s.current
                  ? { backgroundColor: colors.warningSoft, borderWidth: 2, borderColor: colors.border }
                  : { backgroundColor: colors.muted, borderWidth: 1, borderColor: colors.border };
              const titleColor = s.done ? (infoStep ? colors.info : colors.success) : s.current ? colors.warning : colors.mutedForeground;
              return (
                <View key={idx} style={styles.step}>
                  <View style={styles.stepHead}>
                    <View style={[styles.stepCircle, circle]}>
                      {s.done ? (
                        infoStep ? <ArrowDownToLine color="#ffffff" size={14} /> : <Check color="#ffffff" size={14} />
                      ) : s.current ? (
                        <Clock3 color={colors.warning} size={14} />
                      ) : (
                        <Text style={styles.stepNumber}>{idx + 1}</Text>
                      )}
                    </View>
                    <Text style={[styles.stepTitle, { color: titleColor }]}>{s.title}</Text>
                  </View>
                  <Text style={styles.stepDesc}>{s.desc}</Text>
                </View>
              );
            })}
          </View>
        ))}
      </View>
    </Card>
  );
}

/** Web `/app/orders/[id]` → UserOrderDetailPage. */
export default function OrderDetailScreen() {
  const t = useCopy();
  const toast = useToast();
  const { id } = useLocalSearchParams<{ id: string }>();
  const [copied, setCopied] = useState(false);
  const query = useFinance<FinanceRow>("me/orders/" + id);
  if (query.isLoading) return <Loading />;
  if (query.isError) return <Failure message={query.error.message} retry={() => void query.refetch()} />;
  if (!query.data) return null;

  const data = query.data;
  const orderSn = text(data, "orderSn");
  const platform = (read(data, "platform") || read(data, "productSummary.platform") || "Shopee") as string;
  const orderStatus = text(data, "status");
  const commissionState = text(data, "checkout.commission.state");
  const cashbackState = read(data, "checkout.commission.cashback.state") as string | undefined;
  const cashbackAmount = text(data, "checkout.commission.cashback.userAmount");
  const totalAmountVnd = text(data, "totalAmountVnd");
  const purchasedAt = read(data, "checkout.purchasedAt") as string | undefined;
  const items = (read(data, "items") as FinanceRow[]) ?? [];

  const copyOrderSn = () => {
    if (!orderSn || orderSn === "—") return;
    Clipboard.setStringAsync(orderSn)
      .then(() => {
        setCopied(true);
        toast.success(t("Đã sao chép mã đơn"));
        setTimeout(() => setCopied(false), 2000);
      })
      .catch(() => toast.error(t("Không thể sao chép")));
  };

  const computedTotal =
    totalAmountVnd !== "—"
      ? totalAmountVnd
      : items
          .reduce((sum, item) => {
            const raw = text(item, "actualAmountRaw");
            const scale = text(item, "scale") === "100000" ? 100000n : 1n;
            return sum + (raw === "—" ? 0n : BigInt(raw) / scale);
          }, 0n)
          .toString();
  const userBps = read(data, "checkout.commission.cashback.userBps");
  const ratePercent = userBps ? `${Number(userBps) / 100}%` : "85%";
  const cashback = formatVnd(cashbackAmount === "—" ? "0" : cashbackAmount);

  return (
    <Page
      title={t("Chi tiết đơn hàng")}
      description={purchasedAt ? `${t("Thời gian đặt hàng:")} ${formatDateTime(purchasedAt)}` : undefined}
      badge={
        <View style={styles.badgeRow}>
          <PlatformChip platform={platform} large />
          <Text style={styles.orderSn}>#{orderSn}</Text>
          <Pressable
            accessibilityLabel={t("Sao chép mã đơn")}
            onPress={copyOrderSn}
            style={({ pressed }) => [styles.copyBtn, pressed && { backgroundColor: colors.muted }]}
          >
            {copied ? <Check color={colors.success} size={14} /> : <Copy color={colors.mutedForeground} size={14} />}
          </Pressable>
        </View>
      }
    >
      {/* 1. Header overview */}
      <Card style={styles.overview}>
        <View style={styles.statusRow}>
          <View>
            <Text style={styles.caption}>{t("Trạng thái đơn hàng")}</Text>
            <View style={styles.badgeLine}>
              <StatusBadge domain="order" status={orderStatus} />
            </View>
          </View>
          <View>
            <Text style={styles.caption}>{t("Trạng thái hoa hồng")}</Text>
            <View style={styles.badgeLine}>
              <StatusBadge domain="commission" status={commissionState} />
            </View>
          </View>
          {cashbackState ? (
            <View>
              <Text style={styles.caption}>{t("Trạng thái hoàn tiền")}</Text>
              <View style={styles.badgeLine}>
                <StatusBadge domain="cashback" status={cashbackState} />
              </View>
            </View>
          ) : null}
        </View>
        <View>
          <Text style={styles.muted12}>{t("Tiền hoàn tích lũy")}</Text>
          <Text style={styles.bigCashback}>+{cashback}</Text>
        </View>
      </Card>

      {/* 2. Progress stepper */}
      <CashbackProgressStepper
        orderStatus={orderStatus}
        commissionState={commissionState}
        cashbackState={cashbackState}
        purchasedAt={purchasedAt}
      />

      {/* 3. Products */}
      <Card style={styles.space16}>
        <View style={[styles.between, styles.itemsHead]}>
          <View style={[styles.inlineIcon8, styles.shrink]}>
            <ShoppingBag color={colors.primary} size={20} style={styles.noShrink} />
            <Text style={[styles.h2, styles.shrink]}>
              {t("Sản phẩm trong đơn")} ({items.length})
            </Text>
          </View>
          <Text style={[styles.muted12, styles.shrink]}>
            {t("Tổng cộng:")}{" "}
            <Text style={styles.strong12}>
              {items.length} {t("sản phẩm")}
            </Text>
          </Text>
        </View>
        <View>
          {items.map((item, index) => {
            const itemScale = text(item, "scale") === "100000" ? 100000n : 1n;
            const rawAmount = text(item, "actualAmountRaw");
            const actualAmountVnd = rawAmount === "—" ? 0n : BigInt(rawAmount) / itemScale;
            const rawPrice = text(item, "itemPriceRaw");
            const itemPriceVnd = rawPrice === "—" ? actualAmountVnd : BigInt(rawPrice) / itemScale;
            const itemName = text(item, "itemName") === "—" ? text(item, "payload.item_name") : text(item, "itemName");
            const imageUrl = (read(item, "image") || read(item, "imageUrl") || read(item, "payload.image")) as string | null;
            const itemUrl = (read(item, "itemUrl") || read(item, "item_url") || read(item, "payload.item_url")) as string | null;
            const qty = Number(read(item, "qty") ?? 1);
            const itemStatus = text(item, "status");
            const commissionStatus = text(item, "commissionStatus");
            return (
              <View key={item.id} style={[styles.item, index > 0 && styles.itemDivider]}>
                <View style={styles.thumbShadow}>
                  <ProductThumbnail src={imageUrl} name={itemName} size={80} />
                </View>
                <View style={styles.itemBody}>
                  <Text numberOfLines={2} style={styles.itemName}>
                    {itemName}
                  </Text>
                  <View style={styles.itemMeta}>
                    <View style={styles.qty}>
                      <Text style={styles.qtyText}>
                        {t("Số lượng:")} x{qty}
                      </Text>
                    </View>
                    <Text style={styles.muted12}>
                      {t("Đơn giá:")}{" "}
                      <Text style={styles.strongFg12}>
                        {itemPriceVnd === 0n ? t("0 đ (Quà tặng)") : formatVnd(itemPriceVnd)}
                      </Text>
                    </Text>
                    {itemUrl ? (
                      <Pressable accessibilityRole="link" onPress={() => void Linking.openURL(itemUrl)} style={styles.inlineIcon4}>
                        <Text style={styles.itemLink}>{t("Xem trên sàn")}</Text>
                        <ExternalLink color={colors.primary} size={12} />
                      </Pressable>
                    ) : null}
                  </View>
                  <View style={styles.itemBadges}>
                    <StatusBadge status={itemStatus} domain="order" />
                    {commissionStatus !== "—" ? <StatusBadge status={commissionStatus} domain="commission" /> : null}
                  </View>
                </View>
                <View style={styles.itemTotal}>
                  <Text style={styles.muted12}>{t("Thành tiền:")}</Text>
                  <View style={styles.amountLine}>
                    <Text style={styles.itemAmount}>
                      {actualAmountVnd === 0n ? t("0 đ (Quà tặng)") : formatVnd(actualAmountVnd)}
                    </Text>
                  </View>
                </View>
              </View>
            );
          })}
        </View>
      </Card>

      {/* 4. Financial summary */}
      <Card style={styles.space16}>
        <Text style={styles.h2}>{t("Chi tiết dòng tiền & Tích lũy")}</Text>
        <View style={styles.receipt}>
          <View style={styles.between}>
            <Text style={styles.muted14}>{t("Tổng giá trị mua hàng:")}</Text>
            <Text style={styles.semibold14}>{formatVnd(computedTotal)}</Text>
          </View>
          <View style={styles.between}>
            <Text style={styles.muted14}>{t("Tỷ lệ tích lũy Piggy Back:")}</Text>
            <Text style={[styles.semibold14, { color: colors.primary }]}>{ratePercent}</Text>
          </View>
          <View style={[styles.between, styles.receiptTotal]}>
            <Text style={styles.semibold14}>{t("Tiền hoàn thực nhận:")}</Text>
            <Text style={styles.receiptCashback}>+{cashback}</Text>
          </View>
        </View>
        {cashbackState === "AVAILABLE" ? (
          <View style={styles.available}>
            <View style={[styles.inlineIcon8, styles.flex1]}>
              <Wallet color={colors.success} size={20} style={styles.noShrink} />
              <Text style={styles.availableText}>{t("Số tiền này đã sẵn sàng rút về tài khoản ngân hàng của bạn!")}</Text>
            </View>
            <Pressable accessibilityRole="link" onPress={() => router.push("/withdrawals/new")} style={styles.withdrawNow}>
              <Text style={styles.withdrawNowText}>{t("Rút tiền ngay")}</Text>
            </Pressable>
          </View>
        ) : null}
        <View style={styles.policy}>
          <ShieldCheck color={colors.primary} size={16} style={styles.policyIcon} />
          <Text style={styles.policyText}>
            <Text style={styles.policyStrong}>{t("Chính sách đối soát:")}</Text>{" "}
            {t(
              "Hoa hồng đơn hàng từ Shopee & TikTok Shop cần thời gian đối soát từ 30 đến 45 ngày để xác nhận hoàn tất (không đổi trả hoặc phát sinh khiếu nại). Sau khi sàn hoàn tất quyết toán, tiền sẽ tự động chuyển sang trạng thái 'Có thể rút'.",
            )}
          </Text>
        </View>
      </Card>
    </Page>
  );
}

const styles = StyleSheet.create({
  flex1: { flex: 1, minWidth: 0 },
  // CSS flex items default to flex-shrink: 1, so both sides of a justify-between row wrap.
  shrink: { flexShrink: 1, minWidth: 0 },
  // CSS never shrinks a replaced <svg> below its size; Yoga would.
  noShrink: { flexShrink: 0 },
  space16: { gap: 16 },
  // web `flex items-center justify-between` rows here have no gap
  between: { flexDirection: "row", alignItems: "center", justifyContent: "space-between" },
  inlineIcon: { flexDirection: "row", alignItems: "center", gap: 4 },
  inlineIcon4: { flexDirection: "row", alignItems: "center", gap: 4 },
  inlineIcon8: { flexDirection: "row", alignItems: "center", gap: 8 },
  badgeRow: { flexDirection: "row", flexWrap: "wrap", alignItems: "center", gap: 8 },
  orderSn: { fontFamily: mono, fontSize: 16, lineHeight: 24, fontWeight: "600", color: colors.foreground },
  copyBtn: {
    width: 28,
    height: 28,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.border,
    alignItems: "center",
    justifyContent: "center",
  },
  overview: { gap: 16 },
  statusRow: { flexDirection: "row", flexWrap: "wrap", alignItems: "center", gap: 16 },
  // inline-flex badge in a 16/24 block: the line box ends 1px below the 24px badge.
  badgeLine: { paddingBottom: 1 },
  // block wrapper inherits the 16/24 line box around the 14px amount
  amountLine: { height: 24, justifyContent: "center" },
  caption: { ...font(12), color: colors.mutedForeground, marginBottom: 4 },
  muted12: { ...font(12), color: colors.mutedForeground },
  muted14: { ...font(14), color: colors.mutedForeground },
  strong12: { ...font(12, 700), color: colors.mutedForeground },
  strongFg12: { ...font(12, 700), color: colors.foreground },
  bigCashback: { ...font(24, 900), color: colors.success, fontVariant: ["tabular-nums"] },
  cancelled: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.dangerSoft,
    padding: 16,
  },
  cancelledTitle: { ...font(16, 600), color: colors.danger },
  cancelledText: { ...font(12), color: colors.danger, opacity: 0.9 },
  overline: { ...font(12, 700), letterSpacing: 0.6, color: colors.mutedForeground, flexShrink: 1 },
  toneText: { ...font(12, 600), flexShrink: 1 },
  stepGrid: { gap: 16 },
  stepRow: { flexDirection: "row", gap: 16 },
  step: { flex: 1, minWidth: 0, gap: 6 },
  stepHead: { flexDirection: "row", alignItems: "center", gap: 8 },
  stepCircle: { width: 28, height: 28, borderRadius: 14, alignItems: "center", justifyContent: "center" },
  stepNumber: { ...font(12, 700), color: colors.mutedForeground },
  stepTitle: { ...font(14, 600), flexShrink: 1 },
  stepDesc: { ...font(12), color: colors.mutedForeground, paddingLeft: 36 },
  itemsHead: { borderBottomWidth: 1, borderBottomColor: colors.border, paddingBottom: 12 },
  h2: { ...font(16, 600), color: colors.foreground },
  item: { gap: 16, paddingVertical: 16 },
  itemDivider: { borderTopWidth: 1, borderTopColor: colors.border },
  thumbShadow: { alignSelf: "flex-start", borderRadius: 24, boxShadow: "0 1px 2px rgba(0, 0, 0, 0.05)" },
  itemBody: { gap: 8, minWidth: 0 },
  itemName: { ...font(14, 600, 19.25), color: colors.foreground },
  itemMeta: { flexDirection: "row", flexWrap: "wrap", alignItems: "center", gap: 12 },
  qty: { backgroundColor: colors.muted, borderRadius: 12, paddingHorizontal: 8, paddingVertical: 2 },
  qtyText: { ...font(12, 500), color: colors.mutedForeground },
  itemLink: { ...font(12, 500), color: colors.primary, textDecorationLine: "underline" },
  itemBadges: { flexDirection: "row", flexWrap: "wrap", alignItems: "center", gap: 8, paddingTop: 4 },
  itemTotal: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    borderTopWidth: 1,
    borderTopColor: colors.border,
    paddingTop: 8,
  },
  itemAmount: { ...font(14, 700), color: colors.foreground, fontVariant: ["tabular-nums"] },
  receipt: { gap: 10 },
  semibold14: { ...font(14, 600), color: colors.foreground, fontVariant: ["tabular-nums"] },
  receiptTotal: { borderTopWidth: 1, borderTopColor: colors.border, paddingTop: 10 },
  receiptCashback: { ...font(18, 700), color: colors.success, fontVariant: ["tabular-nums"] },
  available: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 8,
    backgroundColor: colors.successSoft,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 24,
    padding: 12,
  },
  availableText: { ...font(12, 600), color: colors.success, flexShrink: 1 },
  withdrawNow: {
    backgroundColor: colors.success,
    borderRadius: 16,
    paddingHorizontal: 12,
    paddingVertical: 6,
    boxShadow: "0 1px 2px rgba(0, 0, 0, 0.05)",
  },
  // web `text-success-foreground` is not a defined token, so the label inherits the foreground color.
  withdrawNowText: { ...font(12, 600), color: colors.foreground },
  policy: { flexDirection: "row", gap: 10, borderRadius: 24, backgroundColor: extra.muted50, padding: 14 },
  policyIcon: { marginTop: 2 },
  policyText: { ...font(12, 400, 19.5), color: colors.mutedForeground, flex: 1 },
  policyStrong: { ...font(12, 700, 19.5), color: colors.mutedForeground },
});
