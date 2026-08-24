import {onRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

const TELEGRAM_BOT_TOKEN = defineSecret("TELEGRAM_BOT_TOKEN");

const TELEGRAM_API = "https://api.telegram.org";

interface TelegramUpdate {
  update_id: number;
  message?: TelegramMessage;
  callback_query?: TelegramCallbackQuery;
}

interface TelegramMessage {
  message_id: number;
  chat: {
    id: number;
  };
  text?: string;
}

interface TelegramCallbackQuery {
  id: string;
  data?: string;
  message?: TelegramMessage;
}

interface TelegramResponse {
  ok: boolean;
  result?: unknown;
  description?: string;
}

interface InlineKeyboardButton {
  text: string;
  callback_data?: string;
  url?: string;
}

interface InlineKeyboardMarkup {
  inline_keyboard: InlineKeyboardButton[][];
}

interface FaqItem {
  question: string;
  answer: string;
}

const FAQ_ITEMS: Record<string, FaqItem> = {
  faq_about: {
    question: "📋 Что такое Brivora?",
    answer:
      "🏗️ Brivora — приложение для строителей, прорабов и " +
      "ремонтных бригад.\n\n" +
      "В одном месте можно управлять проектами, создавать " +
      "сметы, хранить фотографии, заметки и задачи, а также " +
      "пользоваться строительными калькуляторами.\n\n" +
      "Brivora помогает не держать всю информацию по объекту " +
      "в голове, заметках и переписках.",
  },

  faq_estimate: {
    question: "🧾 Как создать смету?",
    answer:
      "🧾 Чтобы создать смету:\n\n" +
      "1. Откройте нужный проект.\n" +
      "2. Перейдите в раздел «Сметы».\n" +
      "3. Нажмите «Создать смету».\n" +
      "4. Добавьте необходимые работы и материалы.\n" +
      "5. Укажите количество и цену.\n" +
      "6. Brivora автоматически рассчитает итоговую стоимость.\n\n" +
      "Готовую смету можно сохранить и использовать для " +
      "работы с клиентом.",
  },

  faq_project: {
    question: "🏗️ Как создать проект?",
    answer:
      "🏗️ Чтобы создать проект:\n\n" +
      "1. Откройте раздел «Проекты».\n" +
      "2. Нажмите кнопку «+ Создать».\n" +
      "3. Укажите название проекта.\n" +
      "4. Добавьте необходимую информацию об объекте.\n" +
      "5. Сохраните проект.\n\n" +
      "После этого внутри проекта можно вести сметы, " +
      "фотографии, заметки и задачи.",
  },

  faq_photos: {
    question: "📸 Как добавить фотографии?",
    answer:
      "📸 Чтобы добавить фотографии:\n\n" +
      "1. Откройте нужный проект.\n" +
      "2. Перейдите в раздел «Фото».\n" +
      "3. Нажмите кнопку добавления фотографии.\n" +
      "4. Выберите фотографию из галереи или сделайте снимок.\n\n" +
      "Фотографии сохраняются внутри соответствующего проекта, " +
      "поэтому их легко найти позже.",
  },

  faq_notes: {
    question: "📝 Как создать заметку?",
    answer:
      "📝 Чтобы создать заметку:\n\n" +
      "1. Откройте нужный проект.\n" +
      "2. Перейдите в раздел «Заметки».\n" +
      "3. Нажмите «+» или «Создать заметку».\n" +
      "4. Введите текст.\n" +
      "5. Сохраните заметку.\n\n" +
      "Заметка будет привязана к проекту и сохранится " +
      "в базе данных Brivora.",
  },

  faq_tasks: {
    question: "✅ Как создать задачу?",
    answer:
      "✅ Чтобы создать задачу:\n\n" +
      "1. Откройте нужный проект.\n" +
      "2. Перейдите в раздел «Задачи».\n" +
      "3. Нажмите «+ Создать задачу».\n" +
      "4. Укажите название задачи.\n" +
      "5. При необходимости добавьте дату и информацию.\n" +
      "6. Сохраните задачу.\n\n" +
      "После выполнения задачу можно отметить как завершённую.",
  },

  faq_calculators: {
    question: "🧮 Как пользоваться калькуляторами?",
    answer:
      "🧮 В Brivora есть строительные калькуляторы, которые " +
      "помогают быстро рассчитать необходимое количество " +
      "материалов.\n\n" +
      "Например, можно рассчитать материалы для:\n" +
      "• плитки;\n" +
      "• обоев;\n" +
      "• краски;\n" +
      "• ламината;\n" +
      "• бетона.\n\n" +
      "Выберите нужный калькулятор, введите размеры и параметры " +
      "помещения — Brivora выполнит расчёт.",
  },

  faq_data: {
    question: "💾 Где сохраняются данные?",
    answer:
      "💾 Данные Brivora сохраняются в облачной базе данных " +
      "Firebase.\n\n" +
      "Это позволяет хранить проекты, сметы, фотографии, " +
      "заметки и задачи отдельно от самого устройства.\n\n" +
      "При работе с аккаунтом данные привязаны к вашему " +
      "пользователю.",
  },

  faq_register: {
    question: "👤 Как зарегистрироваться?",
    answer:
      "👤 Для регистрации:\n\n" +
      "1. Откройте приложение Brivora.\n" +
      "2. Перейдите на экран регистрации.\n" +
      "3. Введите необходимые данные.\n" +
      "4. Создайте аккаунт.\n\n" +
      "После регистрации вы сможете создавать проекты " +
      "и сохранять свои данные.",
  },

  faq_download: {
    question: "📱 Где скачать приложение?",
    answer:
      "📱 Brivora развивается как мобильное приложение.\n\n" +
      "На текущем этапе основная версия доступна для Android.\n\n" +
      "Следите за официальными каналами Brivora, чтобы " +
      "получать информацию о новых версиях и выходе приложения " +
      "на других платформах.",
  },
};

/**
 * Создаёт клавиатуру с часто задаваемыми вопросами.
 *
 * @return {InlineKeyboardMarkup} Telegram inline keyboard.
 */
function createFaqKeyboard(): InlineKeyboardMarkup {
  return {
    inline_keyboard: [
      [
        {
          text: "📋 Что такое Brivora?",
          callback_data: "faq_about",
        },
      ],
      [
        {
          text: "🧾 Как создать смету?",
          callback_data: "faq_estimate",
        },
        {
          text: "🏗️ Как создать проект?",
          callback_data: "faq_project",
        },
      ],
      [
        {
          text: "📸 Как добавить фотографии?",
          callback_data: "faq_photos",
        },
        {
          text: "📝 Как создать заметку?",
          callback_data: "faq_notes",
        },
      ],
      [
        {
          text: "✅ Как создать задачу?",
          callback_data: "faq_tasks",
        },
        {
          text: "🧮 Как пользоваться калькуляторами?",
          callback_data: "faq_calculators",
        },
      ],
      [
        {
          text: "💾 Где сохраняются данные?",
          callback_data: "faq_data",
        },
        {
          text: "👤 Как зарегистрироваться?",
          callback_data: "faq_register",
        },
      ],
      [
        {
          text: "📱 Где скачать приложение?",
          callback_data: "faq_download",
        },
      ],
    ],
  };
}

/**
 * Создаёт главное меню Telegram-бота.
 *
 * @return {InlineKeyboardMarkup} Main Telegram keyboard.
 */
function createMainKeyboard(): InlineKeyboardMarkup {
  return {
    inline_keyboard: [
      [
        {
          text: "📋 Частые вопросы",
          callback_data: "faq_menu",
        },
      ],
      [
        {
          text: "🤖 AI-помощник",
          callback_data: "ai_info",
        },
        {
          text: "📱 Приложение",
          callback_data: "faq_download",
        },
      ],
    ],
  };
}

/**
 * Отправляет сообщение пользователю Telegram.
 *
 * @param {string} token Telegram bot token.
 * @param {number} chatId Telegram chat ID.
 * @param {string} text Message text.
 * @param {InlineKeyboardMarkup} replyMarkup Optional keyboard.
 * @return {Promise<TelegramResponse>} Telegram API response.
 */
async function sendMessage(
  token: string,
  chatId: number,
  text: string,
  replyMarkup?: InlineKeyboardMarkup,
): Promise<TelegramResponse> {
  const response = await fetch(
    `${TELEGRAM_API}/bot${token}/sendMessage`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        chat_id: chatId,
        text,
        reply_markup: replyMarkup,
      }),
    },
  );

  return (await response.json()) as TelegramResponse;
}

/**
 * Отвечает на callback query Telegram.
 *
 * @param {string} token Telegram bot token.
 * @param {string} callbackQueryId Telegram callback query ID.
 * @return {Promise<TelegramResponse>} Telegram API response.
 */
async function answerCallbackQuery(
  token: string,
  callbackQueryId: string,
): Promise<TelegramResponse> {
  const response = await fetch(
    `${TELEGRAM_API}/bot${token}/answerCallbackQuery`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        callback_query_id: callbackQueryId,
      }),
    },
  );

  return (await response.json()) as TelegramResponse;
}

/**
 * Возвращает главное приветственное сообщение.
 *
 * @return {string} Welcome message.
 */
function getWelcomeMessage(): string {
  return (
    "👋 Привет! Это официальный Telegram-бот Brivora.\n\n" +
    "🏗️ Brivora помогает строителям и прорабам управлять " +
    "проектами, сметами, фотографиями, заметками и задачами.\n\n" +
    "Выберите нужный раздел ниже:"
  );
}

/**
 * Возвращает меню часто задаваемых вопросов.
 *
 * @return {string} FAQ menu text.
 */
function getFaqMessage(): string {
  return (
    "📚 Частые вопросы о Brivora\n\n" +
    "Выберите вопрос, на который хотите получить ответ:"
  );
}

/**
 * Возвращает информацию об AI-помощнике.
 *
 * @return {string} AI assistant information.
 */
function getAiMessage(): string {
  return (
    "🤖 AI-помощник Brivora\n\n" +
    "AI-помощник предназначен для помощи со строительными " +
    "проектами, расчётами, материалами, сметами и организацией " +
    "работ.\n\n" +
    "В приложении вы сможете задать вопрос AI и получить " +
    "структурированный ответ."
  );
}

/**
 * Обрабатывает текстовое сообщение пользователя.
 *
 * @param {string} token Telegram bot token.
 * @param {TelegramMessage} message Telegram message.
 * @return {Promise<void>} Resolves after processing.
 */
async function handleMessage(
  token: string,
  message: TelegramMessage,
): Promise<void> {
  const chatId = message.chat.id;
  const text = message.text?.trim().toLowerCase() ?? "";

  if (text === "/start" || text === "/help") {
    await sendMessage(
      token,
      chatId,
      getWelcomeMessage(),
      createMainKeyboard(),
    );
    return;
  }

  if (
    text === "/faq" ||
    text === "faq" ||
    text === "частые вопросы"
  ) {
    await sendMessage(
      token,
      chatId,
      getFaqMessage(),
      createFaqKeyboard(),
    );
    return;
  }

  await sendMessage(
    token,
    chatId,
    "👋 Я помогу разобраться с Brivora.\n\n" +
      "Нажмите «📋 Частые вопросы», чтобы посмотреть " +
      "инструкции.",
    createMainKeyboard(),
  );
}

/**
 * Обрабатывает нажатие inline-кнопки.
 *
 * @param {string} token Telegram bot token.
 * @param {TelegramCallbackQuery} callbackQuery Callback query.
 * @return {Promise<void>} Resolves after processing.
 */
async function handleCallback(
  token: string,
  callbackQuery: TelegramCallbackQuery,
): Promise<void> {
  const data = callbackQuery.data ?? "";
  const message = callbackQuery.message;

  await answerCallbackQuery(token, callbackQuery.id);

  if (!message) {
    return;
  }

  const chatId = message.chat.id;

  if (data === "main_menu") {
    await sendMessage(
      token,
      chatId,
      getWelcomeMessage(),
      createMainKeyboard(),
    );
    return;
  }

  if (data === "faq_menu") {
    await sendMessage(
      token,
      chatId,
      getFaqMessage(),
      createFaqKeyboard(),
    );
    return;
  }

  if (data === "ai_info") {
    await sendMessage(
      token,
      chatId,
      getAiMessage(),
      {
        inline_keyboard: [
          [
            {
              text: "📚 Частые вопросы",
              callback_data: "faq_menu",
            },
          ],
          [
            {
              text: "⬅️ Главное меню",
              callback_data: "main_menu",
            },
          ],
        ],
      },
    );
    return;
  }

  const faq = FAQ_ITEMS[data];

  if (faq) {
    await sendMessage(
      token,
      chatId,
      `${faq.question}\n\n${faq.answer}`,
      {
        inline_keyboard: [
          [
            {
              text: "📚 Все вопросы",
              callback_data: "faq_menu",
            },
          ],
          [
            {
              text: "⬅️ Главное меню",
              callback_data: "main_menu",
            },
          ],
        ],
      },
    );
  }
}

/**
 * Telegram webhook для Brivora.
 *
 * @param {object} request Firebase HTTP request.
 * @param {object} response Firebase HTTP response.
 * @return {Promise<void>} Resolves after processing.
 */
export const telegramBot = onRequest(
  {
    region: "europe-west1",
    secrets: [TELEGRAM_BOT_TOKEN],
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).send("Method Not Allowed");
      return;
    }

    const token = TELEGRAM_BOT_TOKEN.value();

    if (!token) {
      console.error(
        "TELEGRAM_BOT_TOKEN is not configured.",
      );
      response.status(500).send(
        "Telegram bot token is not configured.",
      );
      return;
    }

    try {
      const update = request.body as TelegramUpdate;

      if (
        !update ||
        typeof update.update_id !== "number"
      ) {
        response.status(400).send(
          "Invalid Telegram update.",
        );
        return;
      }

      if (update.message) {
        await handleMessage(token, update.message);
      }

      if (update.callback_query) {
        await handleCallback(
          token,
          update.callback_query,
        );
      }

      response.status(200).send("OK");
    } catch (error) {
      console.error(
        "telegramWebhook error:",
        error,
      );
      response.status(500).send(
        "Internal Server Error",
      );
    }
  },
);

