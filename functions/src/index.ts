import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {setGlobalOptions} from "firebase-functions/v2";

import {
  getSubscription,
  isProSubscription,
} from "./subscriptions/service";

export {telegramBot} from "./telegram";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

setGlobalOptions({
  maxInstances: 10,
});


// ─────────────────────────────────────────────
// Brivora AI
// ─────────────────────────────────────────────

export const brivoraAI = onCall(
  {
    region: "europe-west1",
    secrets: [OPENAI_API_KEY],
    timeoutSeconds: 120,
    memory: "512MiB",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Пользователь не авторизован.",
      );
    }

    const subscription = await getSubscription(request.auth.uid);

    if (!isProSubscription(subscription)) {
      throw new HttpsError(
        "permission-denied",
        "Функция AI доступна только пользователям с активной Pro-подпиской.",
      );
    }

    const message = request.data?.message;

    if (
      typeof message !== "string" ||
      message.trim().length === 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Сообщение не может быть пустым.",
      );
    }

    const apiKey = OPENAI_API_KEY.value();

    if (!apiKey) {
      throw new HttpsError(
        "failed-precondition",
        "AI API ключ не настроен.",
      );
    }

    try {
      const response = await fetch(
        "https://api.openai.com/v1/responses",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${apiKey}`,
          },
          body: JSON.stringify({
            model: "gpt-5-mini",
            input: [
              {
                role: "system",
                content: [
                  {
                    type: "input_text",
                    text:
                      "Ты — AI-помощник приложения Brivora. " +
                      "Помогай пользователям со строительными " +
                      "проектами, расчётами, сметами, задачами " +
                      "и организацией работ. " +
                      "Отвечай понятно, структурированно и по делу. " +
                      "Если пользователь просит расчёт, показывай " +
                      "ход расчёта и необходимые исходные данные.",
                  },
                ],
              },
              {
                role: "user",
                content: [
                  {
                    type: "input_text",
                    text: message.trim(),
                  },
                ],
              },
            ],
          }),
        },
      );

      if (!response.ok) {
        const errorText = await response.text();

        console.error("AI API error:", errorText);

        throw new HttpsError(
          "internal",
          "Не удалось получить ответ от AI.",
        );
      }

      const result = await response.json();

      const outputText = result.output_text;

      if (
        typeof outputText !== "string" ||
        outputText.trim().length === 0
      ) {
        throw new HttpsError(
          "internal",
          "AI вернул пустой ответ.",
        );
      }

      return {
        success: true,
        message: outputText.trim(),
      };
    } catch (error) {
      console.error("brivoraAI error:", error);

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        "Произошла ошибка при обращении к AI.",
      );
    }
  },
);


// ─────────────────────────────────────────────
// Subscription status
// ─────────────────────────────────────────────

export const getSubscriptionStatus = onCall(
  {
    region: "europe-west1",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Пользователь не авторизован.",
      );
    }

    const uid = request.auth.uid;

    try {
      const subscription = await getSubscription(uid);

      const isPro = isProSubscription(subscription);

      return {
        success: true,
        isPro,
        subscription: subscription ?
          {
            plan: subscription.plan,
            status: subscription.status,
            startedAt:
                subscription.startedAt?.toMillis() ?? null,
            expiresAt:
                subscription.expiresAt?.toMillis() ?? null,
            provider:
                subscription.provider ?? null,
            paymentId:
                subscription.paymentId ?? null,
          } :
          null,
      };
    } catch (error) {
      console.error(
        "getSubscriptionStatus error:",
        error,
      );

      throw new HttpsError(
        "internal",
        "Не удалось получить статус подписки.",
      );
    }
  },
);
