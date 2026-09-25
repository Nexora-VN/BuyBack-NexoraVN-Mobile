module.exports = {
  preset: "jest-expo",
  setupFiles: ["<rootDir>/jest.setup.js"],
  moduleNameMapper: {
    // lucide-react-native ships ESM-only for the "react-native" export
    // condition; force Jest to resolve its CJS build instead so it
    // doesn't need special transformIgnorePatterns handling.
    "^lucide-react-native$": "<rootDir>/node_modules/lucide-react-native/dist/cjs/lucide-react-native.js",
  },
};
