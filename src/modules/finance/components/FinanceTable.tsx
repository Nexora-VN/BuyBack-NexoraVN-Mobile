import { Search, SlidersHorizontal } from "lucide-react-native";
import { useEffect, useRef, useState, type ReactNode } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import Svg, { Polygon } from "react-native-svg";
import { Failure, Loading } from "../../../components/patterns/QueryState";
import { Sheet } from "../../../components/patterns/Sheet";
import { Button } from "../../../components/ui/Button";
import { Input, Select } from "../../../components/ui/Input";
import { EmptyState } from "../../../components/ui/Page";
import { statusLabel, type StatusDomain } from "../../../components/ui/StatusBadge";
import { colors, font } from "../../../constants/colors";
import { useCopy } from "../../../i18n/use-copy";
import type { FinanceRow } from "../../../types/finance";
import { useFinanceList, useListState } from "../use-finance";
import { CellStyle, columns, type Column, type Specs } from "./columns";

function domainOf(path: string): StatusDomain {
  return path.includes("orders")
    ? "order"
    : path.includes("commissions")
      ? "commission"
      : path.includes("cashbacks")
        ? "cashback"
        : path.includes("withdrawals")
          ? "withdrawal"
          : path.includes("bank-accounts")
            ? "bank"
            : path.includes("settlements")
              ? "settlement"
              : "general";
}

/** Port of web `FinanceTable` at mobile width (search + "Lọc" sheet, card list, pagination). */
export function FinanceTable({
  path,
  specs,
  states,
  actions,
  searchLabel = "Tìm kiếm",
}: {
  path: string;
  specs: Specs;
  states?: string[];
  actions?: (row: FinanceRow) => ReactNode;
  searchLabel?: string;
}) {
  const t = useCopy();
  const list = useListState();
  const [filters, setFilters] = useState(false);
  const domain = domainOf(path);
  const query = useFinanceList(path, list.page, list.status, list.query, list.sort);
  const cols: Column<FinanceRow>[] = [
    ...columns(specs, domain),
    ...(actions ? [{ key: "actions", label: t("Thao tác"), render: actions }] : []),
  ];
  const filterCount = Number(!!list.status) + Number(list.sort === "asc");
  const apply = (values: Parameters<typeof list.update>[0]) => list.update({ ...values, page: 1 });

  return (
    <View style={styles.section}>
      <View style={styles.toolbar}>
        <ListSearch value={list.query} label={searchLabel} onSearch={(q) => apply({ query: q })} />
        <Button variant="outline" icon={SlidersHorizontal} onPress={() => setFilters(true)}>
          <Text style={styles.filterLabel}>{t("Lọc")}</Text>
          {filterCount > 0 ? (
            <View style={styles.filterCount}>
              <Text style={styles.filterCountText}>{filterCount}</Text>
            </View>
          ) : null}
        </Button>
      </View>
      <Sheet compact open={filters} onOpenChange={setFilters} title={t("Bộ lọc")}>
        <View style={styles.filterBody}>
          {states ? (
            <View style={styles.field}>
              <Text style={styles.fieldLabel}>{t("Trạng thái")}</Text>
              <Select
                title={t("Trạng thái")}
                value={list.status}
                onChange={(status) => apply({ status })}
                options={[
                  { value: "", label: t("Tất cả trạng thái") },
                  ...states.map((s) => ({ value: s, label: t(statusLabel(s, domain)) })),
                ]}
              />
            </View>
          ) : null}
          <View style={styles.field}>
            <Text style={styles.fieldLabel}>{t("Sắp xếp")}</Text>
            <Select
              title={t("Sắp xếp")}
              value={list.sort}
              onChange={(sort) => apply({ sort })}
              options={[
                { value: "desc", label: t("Mới nhất") },
                { value: "asc", label: t("Cũ nhất") },
              ]}
            />
          </View>
          <View style={styles.filterActions}>
            <Button variant="outline" label={t("Xóa bộ lọc")} onPress={() => apply({ query: "", status: "", sort: "desc" })} />
            <Button label={t("Xem kết quả")} onPress={() => setFilters(false)} />
          </View>
        </View>
      </Sheet>
      {query.isLoading ? (
        <Loading />
      ) : query.isError ? (
        <Failure error={query.error} message={query.error.message} retry={() => void query.refetch()} />
      ) : !query.data?.data.length ? (
        <EmptyState
          title={list.query || list.status ? t("Không tìm thấy kết quả") : t("Chưa có dữ liệu")}
          description={
            list.query || list.status
              ? t("Thử thay đổi từ khóa hoặc bộ lọc.")
              : t("Dữ liệu của bạn sẽ xuất hiện sau khi dữ liệu của bạn được đồng bộ")
          }
        />
      ) : (
        <DataTable columns={cols} rows={query.data.data} />
      )}
      {query.data ? (
        <View style={styles.pagination}>
          <Text style={styles.pageText}>
            {query.data.meta.total} {t("bản ghi")} · {t("Trang")} {list.page}/{Math.max(1, query.data.meta.totalPages)}
          </Text>
          {/* outline buttons inherit the row's text-muted-foreground on the web */}
          <View style={styles.pageButtons}>
            <Button
              variant="outline"
              label={t("Trước")}
              color={colors.mutedForeground}
              disabled={list.page <= 1 || query.isFetching}
              onPress={() => list.update({ page: list.page - 1 })}
            />
            <Button
              variant="outline"
              label={t("Sau")}
              color={colors.mutedForeground}
              disabled={list.page >= query.data.meta.totalPages || query.isFetching}
              onPress={() => list.update({ page: list.page + 1 })}
            />
          </View>
        </View>
      ) : null}
    </View>
  );
}

/** web `ListSearch`: remounts the form when the committed value changes (e.g. "Xóa bộ lọc"). */
function ListSearch({ value, onSearch, label }: { value: string; onSearch: (value: string) => void; label: string }) {
  return <SearchForm key={value} value={value} onSearch={onSearch} label={label} />;
}

/** web `SearchForm`: debounced (300ms) input + outline icon submit button. */
function SearchForm({ value, onSearch, label }: { value: string; onSearch: (value: string) => void; label: string }) {
  const t = useCopy();
  const [draft, setDraft] = useState(value);
  const searchRef = useRef(onSearch);
  useEffect(() => {
    searchRef.current = onSearch;
  }, [onSearch]);
  useEffect(() => {
    if (draft.trim() === value) return;
    const timer = setTimeout(() => searchRef.current(draft.trim()), 300);
    return () => clearTimeout(timer);
  }, [draft, value]);
  return (
    <View style={styles.search}>
      <View style={styles.searchInput}>
        <Input
          accessibilityLabel={t(label)}
          placeholder={t(label)}
          value={draft}
          onChangeText={setDraft}
          returnKeyType="search"
          onSubmitEditing={() => onSearch(draft.trim())}
        />
      </View>
      <Button variant="outline" size="icon" icon={Search} accessibilityLabel={t("Tìm kiếm")} onPress={() => onSearch(draft.trim())} />
    </View>
  );
}

/** web `DataTable` mobile branch (`lg:hidden` card list). */
export function DataTable({ columns: cols, rows }: { columns: Column<FinanceRow>[]; rows: FinanceRow[] }) {
  const primary =
    cols.find((c) => c.mobilePrimary) ||
    cols.find((c) => ["product", "user", "orderSn", "reference", "item", "name", "title"].includes(c.key)) ||
    cols[0];
  const actions = cols.filter((c) => ["actions", "action"].includes(c.key));
  const secondary = cols.filter((c) => c !== primary && !actions.includes(c));
  return (
    <View style={styles.cards}>
      {rows.map((row) => (
        <RowCard key={row.id} row={row} primary={primary} secondary={secondary} actions={actions} />
      ))}
    </View>
  );
}

function pairs<T>(items: T[]): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < items.length; i += 2) out.push(items.slice(i, i + 2));
  return out;
}

function RowCard({
  row,
  primary,
  secondary,
  actions,
}: {
  row: FinanceRow;
  primary?: Column<FinanceRow>;
  secondary: Column<FinanceRow>[];
  actions: Column<FinanceRow>[];
}) {
  const t = useCopy();
  const [open, setOpen] = useState(false);
  return (
    <View style={styles.card}>
      <CellStyle.Provider value={styles.primaryText}>
        <View style={styles.primary}>{primary?.render(row)}</View>
      </CellStyle.Provider>
      <View style={styles.grid}>
        {pairs(secondary.slice(0, 4)).map((pair) => (
          <View key={pair[0].key} style={styles.gridRow}>
            {[0, 1].map((i) =>
              pair[i] ? (
                <View key={pair[i].key} style={styles.gridItem}>
                  <Text style={[styles.dt, styles.dtGap]}>{t(pair[i].label)}</Text>
                  <CellStyle.Provider value={styles.dd}>{pair[i].render(row)}</CellStyle.Provider>
                </View>
              ) : (
                <View key="spacer" style={styles.gridItem} />
              ),
            )}
          </View>
        ))}
      </View>
      {secondary.length > 4 ? (
        <View style={styles.details}>
          <Pressable accessibilityRole="button" accessibilityState={{ expanded: open }} onPress={() => setOpen((v) => !v)} style={styles.summary}>
            <View style={styles.summaryRow}>
              {/* Chrome's <details> disclosure marker: a 7.8×9.2 triangle, text starting 15px in. */}
              <Svg width={10} height={10} viewBox="0 0 10 10" style={open ? styles.markerOpen : undefined}>
                <Polygon points="0,0 7.8,4.6 0,9.2" fill={colors.primary} />
              </Svg>
              <Text style={styles.summaryText}>{t("Thông tin thêm")}</Text>
            </View>
          </Pressable>
          {open ? (
            <View style={styles.detailList}>
              {secondary.slice(4).map((c) => (
                <View key={c.key}>
                  <Text style={styles.dt}>{t(c.label)}</Text>
                  <CellStyle.Provider value={styles.dd}>{c.render(row)}</CellStyle.Provider>
                </View>
              ))}
            </View>
          ) : null}
        </View>
      ) : null}
      {actions.length ? (
        <View style={styles.actions}>
          {actions.map((c) => (
            <View key={c.key} style={styles.actionWrap}>
              {c.render(row)}
            </View>
          ))}
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  section: { gap: 16, minWidth: 0 },
  toolbar: { flexDirection: "row", alignItems: "flex-end", gap: 12 },
  search: { flex: 1, minWidth: 0, flexDirection: "row", gap: 8 },
  searchInput: { flex: 1, minWidth: 0 },
  filterLabel: { ...font(14, 500), color: colors.foreground },
  filterCount: { backgroundColor: colors.secondary, borderRadius: 9999, paddingHorizontal: 8 },
  filterCountText: { ...font(14, 500), color: colors.primary },
  filterBody: { gap: 16 },
  // <label class="block space-y-1"> around an inline span + select: no visible gap (measured).
  field: {},
  // inline span in a text-sm label line box sits 1px lower
  fieldLabel: { ...font(14, 400, 19), paddingTop: 1, color: colors.foreground },
  filterActions: { flexDirection: "row", gap: 8 },
  pagination: { flexDirection: "row", flexWrap: "wrap", alignItems: "center", justifyContent: "space-between", gap: 12 },
  pageText: { ...font(14), color: colors.mutedForeground },
  pageButtons: { flexDirection: "row", gap: 8 },
  cards: { gap: 12 },
  card: { backgroundColor: colors.card, borderRadius: 16, borderWidth: 1, borderColor: colors.border, padding: 16, minWidth: 0 },
  primary: { minWidth: 0 },
  primaryText: { ...font(16, 600), color: colors.foreground },
  grid: { marginTop: 12, gap: 12 },
  gridRow: { flexDirection: "row", gap: 16 },
  gridItem: { flex: 1, minWidth: 0 },
  dt: { ...font(12), color: colors.mutedForeground },
  dtGap: { marginBottom: 4 },
  dd: { ...font(14), color: colors.foreground },
  details: { marginTop: 12, borderTopWidth: 1, borderTopColor: colors.border, paddingTop: 12 },
  summary: { minHeight: 44 },
  summaryRow: { flexDirection: "row", alignItems: "center", gap: 5 },
  markerOpen: { transform: [{ rotate: "90deg" }] },
  summaryText: { ...font(14, 500), color: colors.primary },
  detailList: { gap: 12 },
  actions: {
    marginTop: 16,
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
    borderTopWidth: 1,
    borderTopColor: colors.border,
    paddingTop: 12,
  },
  actionWrap: { flexDirection: "row", flexWrap: "wrap", gap: 8 },
});
