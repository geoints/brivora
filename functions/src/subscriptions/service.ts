import admin from "../firebaseAdmin";

import {
  Subscription,
  SubscriptionPlan,
  PaymentProvider,
} from "./types";

const db = admin.firestore();

/**
 * Gets a user's subscription from Firestore.
 *
 * @param {string} uid Firebase Auth user UID.
 * @return {Promise<Subscription | null>} User subscription or null.
 */
export async function getSubscription(
  uid: string,
): Promise<Subscription | null> {
  const userRef = db.collection("users").doc(uid);
  const snapshot = await userRef.get();

  if (!snapshot.exists) {
    return null;
  }

  const data = snapshot.data();

  if (!data?.subscription) {
    return null;
  }

  return data.subscription as Subscription;
}

/**
 * Checks whether a subscription is currently active.
 *
 * @param {Subscription | null} subscription User subscription.
 * @return {boolean} True when subscription is active and not expired.
 */
export function isSubscriptionActive(
  subscription: Subscription | null,
): boolean {
  if (!subscription) {
    return false;
  }

  if (subscription.status !== "active") {
    return false;
  }

  if (!subscription.expiresAt) {
    return false;
  }

  return subscription.expiresAt.toMillis() > Date.now();
}

/**
 * Checks whether a user has an active Pro subscription.
 *
 * @param {Subscription | null} subscription User subscription.
 * @return {boolean} True when the user has an active Pro subscription.
 */
export function isProSubscription(
  subscription: Subscription | null,
): boolean {
  return isSubscriptionActive(subscription);
}

/**
 * Activates a user's subscription after confirmed payment.
 *
 * @param {object} params Subscription activation parameters.
 * @return {Promise<void>} Promise resolved after subscription is saved.
 */
export async function activateSubscription(params: {
  uid: string;
  plan: SubscriptionPlan;
  provider: PaymentProvider;
  paymentId: string;
  durationDays: number;
}): Promise<void> {
  const {
    uid,
    plan,
    provider,
    paymentId,
    durationDays,
  } = params;

  const now = admin.firestore.Timestamp.now();

  const expiresAt = admin.firestore.Timestamp.fromMillis(
    now.toMillis() +
      durationDays * 24 * 60 * 60 * 1000,
  );

  const subscription: Subscription = {
    plan,
    status: "active",
    startedAt: now,
    expiresAt,
    provider,
    paymentId,
    updatedAt: now,
  };

  await db.collection("users").doc(uid).set(
    {
      subscription,
    },
    {
      merge: true,
    },
  );
}

/**
 * Cancels a user's subscription.
 *
 * @param {string} uid Firebase Auth user UID.
 * @return {Promise<void>} Promise resolved after subscription is updated.
 */
export async function cancelSubscription(
  uid: string,
): Promise<void> {
  await db.collection("users").doc(uid).set(
    {
      "subscription.status": "cancelled",
      "subscription.updatedAt":
        admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      merge: true,
    },
  );
}

/**
 * Marks a user's subscription as expired.
 *
 * @param {string} uid Firebase Auth user UID.
 * @return {Promise<void>} Promise resolved after subscription is updated.
 */
export async function expireSubscription(
  uid: string,
): Promise<void> {
  await db.collection("users").doc(uid).set(
    {
      "subscription.status": "expired",
      "subscription.updatedAt":
        admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      merge: true,
    },
  );
}
