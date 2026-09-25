/* global jest */
// Screens read safe-area insets; use the library's official Jest mock instead of wrapping every test.
jest.mock("react-native-safe-area-context", () => require("react-native-safe-area-context/jest/mock").default);
