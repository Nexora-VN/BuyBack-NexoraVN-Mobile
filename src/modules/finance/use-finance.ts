import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { financeService } from "../../lib/api/finance-service";

// Port of the web modules/finance/hooks/use-finance.ts.
export function useFinance<T>(path: string) {
  return useQuery({
    queryKey: ["finance", path],
    queryFn: () => financeService.get<T>(path),
    staleTime: 60_000,
  });
}

export function useFinanceList(path: string, page: number, status: string, search: string, sort: string) {
  return useQuery({
    queryKey: ["finance", path, page, status, search, sort],
    queryFn: () => financeService.list(path, page, status, search, sort),
    staleTime: 60_000,
  });
}

export function useRefreshFinance() {
  const client = useQueryClient();
  return () => client.invalidateQueries({ queryKey: ["finance"] });
}

/** Web `useListState` keeps page/status/q/sort in the URL; on mobile they live in screen state. */
export function useListState() {
  const [state, setState] = useState<{ page: number; status: string | null; query: string; sort: "asc" | "desc" }>({
    page: 1,
    status: null,
    query: "",
    sort: "desc",
  });
  function update(values: Partial<{ page: number; status: string; query: string; sort: string }>) {
    setState((prev) => ({
      page: values.page ?? prev.page,
      status: values.status !== undefined ? values.status : prev.status,
      query: values.query ?? prev.query,
      sort: values.sort ? (values.sort === "asc" ? "asc" : "desc") : prev.sort,
    }));
  }
  return {
    page: state.page,
    status: state.status ?? "",
    hasStatus: state.status !== null,
    query: state.query,
    sort: state.sort,
    update,
  };
}
