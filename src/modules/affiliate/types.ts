// Copied from the web frontend (modules/affiliate/types/affiliate.ts).
import type { PaginatedResponse } from "../../types/api";
export type AffiliateLinkStatus = "WORKING" | "FAILED";
export interface AffiliateLink {
  id: string;
  subId1: string | null;
  subId2: string | null;
  subId3: string | null;
  subId4: string | null;
  subId5: string | null;
  originLink: string;
  cleanLink: string;
  convertOrigin: string;
  fullLinkSystem: string | null;
  shortLink: string | null;
  longLink: string | null;
  failCode: number | null;
  affiliateLinkStatus: AffiliateLinkStatus;
  createdAt: string;
  updatedAt: string;
  userId: string;
  productId: string;
}
export type AffiliateList = PaginatedResponse<AffiliateLink>;
export interface GeneratedProduct {
  id: string;
  productName: string;
  shopName: string;
  imageUrl: string;
  price: string | null;
  commission: string | null;
}
export interface GenerateAffiliateResponse {
  link: string | null;
  code: string | number | null;
  product?: GeneratedProduct | null;
}
