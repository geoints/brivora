import admin from "../firebaseAdmin";

import {
  BRIVORA_PAYMENT_PLANS,
  BccPaymentPlan,
  PaymentOrder,
  PaymentOrderStatus,
} from "./types";

const db = admin.firestore();

export async function createPaymentOrder(params: {
  uid: string;
  plan: BccPaymentPlan;
}): Promise<{orderId: string; order: PaymentOrder}> {
  const {uid, plan} = params;
  const pricing = BRIVORA_PAYMENT_PLANS[plan];
  const now = admin.firestore.Timestamp.now();
  const orderRef = db.collection("paymentOrders").doc();

  const order: PaymentOrder = {
    uid,
    plan,
    amount: pricing.amount,
    currency: "KZT",
    provider: "bcc_business",
    status: "pending",
    durationDays: pricing.durationDays,
    createdAt: now,
    updatedAt: now,
  };

  await orderRef.set(order);

  return {orderId: orderRef.id, order};
}

export async function getPaymentOrder(
  uid: string,
  orderId: string,
): Promise<PaymentOrder | null> {
  const snapshot = await db.collection("paymentOrders").doc(orderId).get();

  if (!snapshot.exists) return null;

  const order = snapshot.data() as PaymentOrder;
  if (order.uid !== uid) return null;

  return order;
}

export async function updatePaymentOrderStatus(params: {
  orderId: string;
  status: PaymentOrderStatus;
  providerPaymentId?: string;
}): Promise<void> {
  const {orderId, status, providerPaymentId} = params;

  const data: Record<string, unknown> = {
    status,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (providerPaymentId) data.providerPaymentId = providerPaymentId;
  if (status === "paid") {
    data.paidAt = admin.firestore.FieldValue.serverTimestamp();
  }

  await db.collection("paymentOrders").doc(orderId).update(data);
}
