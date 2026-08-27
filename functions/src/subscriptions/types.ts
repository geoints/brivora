export type SubscriptionPlan = "free" | "monthly" | "yearly";

export type SubscriptionStatus =
  | "active"
  | "expired"
  | "cancelled";

export type PaymentProvider =
  | "kaspi"
  | "cloudpayments"
  | "manual";

export interface Subscription {
  plan: SubscriptionPlan;
  status: SubscriptionStatus;

  startedAt?: FirebaseFirestore.Timestamp;
  expiresAt?: FirebaseFirestore.Timestamp;

  provider?: PaymentProvider;
  paymentId?: string;

  updatedAt?: FirebaseFirestore.Timestamp;
}

export const SUBSCRIPTION_PRICES = {
  free: 0,
  monthly: 3900,
  yearly: 31900,
} as const;
