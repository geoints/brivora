export type BccPaymentPlan = "monthly" | "yearly";

export type PaymentOrderStatus =
  | "pending"
  | "paid"
  | "failed"
  | "cancelled";

export interface PaymentOrder {
  uid: string;
  plan: BccPaymentPlan;
  amount: number;
  currency: "KZT";
  provider: "bcc_business";
  status: PaymentOrderStatus;
  durationDays: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  paidAt?: FirebaseFirestore.Timestamp;
  providerPaymentId?: string;
}

export const BRIVORA_PAYMENT_PLANS = {
  monthly: {
    amount: 3900,
    durationDays: 30,
  },
  yearly: {
    amount: 31900,
    durationDays: 365,
  },
} as const;
