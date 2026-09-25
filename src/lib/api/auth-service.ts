import type { AuthUser, LoginInput, LoginResponse } from "../../types/auth";
import { apiClient } from "./client";
import { clearTokens, setTokens } from "./token-storage";

export const authService = {
  async login(input: LoginInput): Promise<AuthUser> {
    // Like the web BFF, only email/password reach the backend; `remember` controls token persistence.
    const response = await apiClient.post<LoginResponse>(
      "auth/login",
      { email: input.email, password: input.password },
      { skipAuthRefresh: true },
    );
    await setTokens(response.accessToken, response.refreshToken, input.remember !== false);
    return response.user;
  },
  me: () => apiClient.get<AuthUser>("auth/me"),
  async logout(): Promise<void> {
    try {
      await apiClient.post<void>("auth/logout", undefined, { skipAuthRefresh: true });
    } finally {
      await clearTokens();
    }
  },
};
