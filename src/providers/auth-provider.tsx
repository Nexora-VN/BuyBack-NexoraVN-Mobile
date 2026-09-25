import { useQuery, useQueryClient } from "@tanstack/react-query";
import { createContext, useContext, type ReactNode } from "react";
import { authService } from "../lib/api/auth-service";
import { getAccessToken } from "../lib/api/token-storage";
import type { AuthUser, LoginInput } from "../types/auth";

type AuthContextValue = {
  user: AuthUser | null;
  loading: boolean;
  login: (input: LoginInput) => Promise<AuthUser>;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient();
  const query = useQuery({
    queryKey: ["auth", "me"],
    queryFn: async () => {
      const token = await getAccessToken();
      if (!token) return null;
      return authService.me();
    },
    retry: false,
    staleTime: 60_000,
  });

  const login = async (input: LoginInput) => {
    const user = await authService.login(input);
    queryClient.setQueryData(["auth", "me"], user);
    return user;
  };

  const logout = async () => {
    try {
      await authService.logout();
    } finally {
      queryClient.setQueryData(["auth", "me"], null);
      queryClient.removeQueries();
    }
  };

  return (
    <AuthContext.Provider value={{ user: query.data ?? null, loading: query.isLoading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const value = useContext(AuthContext);
  if (!value) throw new Error("useAuth must be used inside AuthProvider");
  return value;
}
