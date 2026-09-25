import type { FinanceList } from "../../types/finance";
import { apiClient } from "./client";

// Port of the web finance service; paths are relative to the backend's /api/v1 (no BFF prefix).
export const financeService = {
  list: (path: string, page: number, status: string, search: string, sort: string) =>
    apiClient.get<FinanceList>(path, { params: { page, limit: 20, status, search, sort } }),
  get: <T>(path: string) => apiClient.get<T>(path),
  mutate: (path: string, body: unknown, method: "post" | "patch" | "put" = "post") =>
    apiClient[method](path, body),
  remove: (path: string) => apiClient.delete(path),
};
