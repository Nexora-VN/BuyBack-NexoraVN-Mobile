import { createContext, useContext, useMemo, useState, type ReactNode } from "react";

type Chrome = { navHidden: boolean; setNavHidden: (hidden: boolean) => void };

const ChromeContext = createContext<Chrome>({ navHidden: false, setNavHidden: () => {} });

/** Shared app-shell state: task-form pages hide the bottom nav (web `.app-page[data-task-form]`). */
export function ChromeProvider({ children }: { children: ReactNode }) {
  const [navHidden, setNavHidden] = useState(false);
  const value = useMemo(() => ({ navHidden, setNavHidden }), [navHidden]);
  return <ChromeContext.Provider value={value}>{children}</ChromeContext.Provider>;
}

export const useChrome = () => useContext(ChromeContext);
