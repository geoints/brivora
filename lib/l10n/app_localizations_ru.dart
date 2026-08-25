// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Brivora';

  @override
  String get home => 'Главная';

  @override
  String get projects => 'Проекты';

  @override
  String get ai => 'ИИ';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get appearance => 'Оформление';

  @override
  String get language => 'Язык';

  @override
  String get russian => 'Русский';

  @override
  String get kazakh => 'Қазақша';

  @override
  String get recentProjects => 'Недавние проекты';

  @override
  String get noRecentProjects => 'Нет недавних проектов';

  @override
  String get tasks => 'Задачи';

  @override
  String get notes => 'Заметки';

  @override
  String get photos => 'Фото';

  @override
  String get estimate => 'Смета';

  @override
  String get calculators => 'Калькуляторы';

  @override
  String get notifications => 'Уведомления';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get close => 'Закрыть';

  @override
  String get back => 'Назад';

  @override
  String get add => 'Добавить';

  @override
  String get done => 'Готово';

  @override
  String get create => 'Создать';

  @override
  String get reset => 'Сбросить';

  @override
  String get retry => 'Повторить';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get systemTheme => 'Как в системе';

  @override
  String get loading => 'Загрузка...';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String helloUser(String name) {
    return 'Здравствуйте, $name';
  }

  @override
  String get projectsDescription => 'Управляйте своими проектами в одном месте';

  @override
  String get noProjects => 'У вас пока нет проектов';

  @override
  String get createFirstProject => 'Создайте свой первый проект';

  @override
  String projectsCount(int count) {
    return '$count';
  }

  @override
  String get completed => 'Завершено';

  @override
  String get inProgress => 'В работе';

  @override
  String get overview => 'Обзор';

  @override
  String get noRecentProjectsTitle => 'Нет недавних проектов';

  @override
  String get noRecentProjectsSubtitle =>
      'Создайте проект, чтобы он появился здесь';

  @override
  String get all => 'Все';

  @override
  String get newProject => 'Новый проект';

  @override
  String get newProjectShort => 'Новый';

  @override
  String get createProject => 'Создать проект';

  @override
  String get materials => 'Материалы';

  @override
  String get untitled => 'Без названия';

  @override
  String get progress => 'Прогресс';

  @override
  String get statusCompleted => 'Завершён';

  @override
  String get statusPlanning => 'Планирование';

  @override
  String get statusArchived => 'Архивирован';

  @override
  String get statusActive => 'Активен';

  @override
  String get openedRecently => 'Открыт недавно';

  @override
  String get openedJustNow => 'Открыт только что';

  @override
  String openedMinutesAgo(int count) {
    return 'Открыт $count мин. назад';
  }

  @override
  String openedHoursAgo(int count) {
    return 'Открыт $count ч. назад';
  }

  @override
  String get openedYesterday => 'Открыт вчера';

  @override
  String openedDaysAgo(int count) {
    return 'Открыт $count дн. назад';
  }

  @override
  String openedDate(String date) {
    return 'Открыт $date';
  }

  @override
  String get updatedJustNow => 'Обновлён только что';

  @override
  String updatedMinutesAgo(int count) {
    return 'Обновлён $count мин. назад';
  }

  @override
  String updatedHoursAgo(int count) {
    return 'Обновлён $count ч. назад';
  }

  @override
  String get updatedYesterday => 'Обновлён вчера';

  @override
  String updatedDaysAgo(int count) {
    return 'Обновлён $count дн. назад';
  }

  @override
  String updatedDate(String date) {
    return 'Обновлён $date';
  }

  @override
  String get newestProjects => 'Новые';

  @override
  String get oldestProjects => 'Старые';

  @override
  String get nameAscending => 'Название А–Я';

  @override
  String get nameDescending => 'Название Я–А';

  @override
  String shownProjects(int count) {
    return 'Показано проектов: $count';
  }

  @override
  String get projectsManagementDescription =>
      'Управляйте строительными проектами';

  @override
  String get searchProjects => 'Поиск проектов...';

  @override
  String get activeProjectsLabel => 'Активные';

  @override
  String get planningProjectsLabel => 'Планирование';

  @override
  String get completedProjectsLabel => 'Завершённые';

  @override
  String get projectsLoadError => 'Не удалось загрузить проекты';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get noProjectsYet => 'Пока нет проектов';

  @override
  String get changeSearchOrFilter => 'Попробуйте изменить поиск или фильтр.';

  @override
  String get createFirstProjectDescription =>
      'Создайте первый проект, чтобы начать работу.';

  @override
  String projectCreated(String title) {
    return 'Проект «$title» создан';
  }

  @override
  String get registration => 'Регистрация';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get createAccountDescription =>
      'Создайте аккаунт, чтобы пользоваться Brivora';

  @override
  String get fullName => 'Полное имя';

  @override
  String get fullNameHint => 'Введите ваше полное имя';

  @override
  String get enterName => 'Введите имя';

  @override
  String get nameMinLength => 'Имя должно содержать минимум 2 символа';

  @override
  String get email => 'Электронная почта';

  @override
  String get emailHint => 'Введите электронную почту';

  @override
  String get enterEmail => 'Введите электронную почту';

  @override
  String get invalidEmail => 'Введите корректный адрес электронной почты';

  @override
  String get password => 'Пароль';

  @override
  String get passwordHint => 'Введите пароль';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get passwordMinLength => 'Пароль должен содержать минимум 6 символов';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get confirmPasswordHint => 'Введите пароль ещё раз';

  @override
  String get confirmPasswordRequired => 'Подтвердите пароль';

  @override
  String get agreeToTerms => 'Я принимаю';

  @override
  String get termsOfUse => 'условия использования';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get login => 'Войти';

  @override
  String get genericError => 'Произошла ошибка';

  @override
  String get emailAlreadyInUse => 'Эта электронная почта уже используется';

  @override
  String get weakPassword => 'Пароль слишком простой';

  @override
  String get invalidEmailAuth => 'Некорректный адрес электронной почты';

  @override
  String get registrationError => 'Не удалось зарегистрировать аккаунт';

  @override
  String get addName => 'Добавьте имя';

  @override
  String get addRoleAndCompany => 'Укажите должность и компанию';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get deletePhoto => 'Удалить фотографию';

  @override
  String get avatarUpdated => 'Аватар успешно обновлён';

  @override
  String avatarUploadError(String error) {
    return 'Не удалось загрузить аватар: $error';
  }

  @override
  String get avatarDeleted => 'Аватар удалён';

  @override
  String avatarDeleteError(String error) {
    return 'Не удалось удалить аватар: $error';
  }

  @override
  String get profileData => 'Данные профиля';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get position => 'Должность';

  @override
  String get positionExample => 'Например: Прораб';

  @override
  String get company => 'Компания';

  @override
  String get companyExample => 'Например: ИП Иванов И.И.';

  @override
  String saveError(String error) {
    return 'Не удалось сохранить: $error';
  }

  @override
  String photosCount(int count) {
    return '$count';
  }

  @override
  String activeProjects(int count) {
    return '$count';
  }

  @override
  String get settingsSubtitle => 'Настройки приложения';

  @override
  String get proSubscription => 'Pro-подписка';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get security => 'Безопасность';

  @override
  String get securitySubtitle => 'Защита аккаунта и данных';

  @override
  String get feedback => 'Обратная связь';

  @override
  String get feedbackSubtitle => 'Помогите улучшить Brivora';

  @override
  String get logout => 'Выйти';

  @override
  String get version => 'Версия';

  @override
  String get logoutQuestion => 'Выйти из аккаунта?';

  @override
  String get logoutConfirmation => 'Вы действительно хотите выйти?';

  @override
  String logoutError(String error) {
    return 'Не удалось выйти: $error';
  }

  @override
  String featureComingSoon(String feature) {
    return '$feature — скоро будет доступно';
  }

  @override
  String get aiAssistant => 'ИИ-помощник';

  @override
  String get online => 'Онлайн';

  @override
  String get aiWhatCanIDo => 'Что я могу сделать?';

  @override
  String get aiWelcomeTitle => 'Чем могу помочь?';

  @override
  String get aiWelcomeDescription =>
      'Спроси меня о ремонте, материалах, расчётах или создании сметы.';

  @override
  String get aiCalculateMaterial => 'Рассчитать материал';

  @override
  String get aiCalculateMaterialSubtitle => 'Плитка, краска, обои';

  @override
  String get aiCreateEstimate => 'Создать смету';

  @override
  String get aiCreateEstimateSubtitle => 'Быстро составить расчёт';

  @override
  String get aiAnalyzePhoto => 'Анализ фото';

  @override
  String get aiAnalyzePhotoSubtitle => 'Найти проблемы на объекте';

  @override
  String get aiRepairAdvice => 'Совет по ремонту';

  @override
  String get aiRepairAdviceSubtitle => 'Получить рекомендацию';

  @override
  String get aiExampleHint =>
      'Например: «Сколько плитки нужно для ванной 3×2 м?»';

  @override
  String get aiMessageHint => 'Напиши сообщение...';

  @override
  String get aiTileAnswer =>
      'Конечно. Для расчёта плитки мне понадобятся размеры помещения, размер одной плитки и желаемый запас. Обычно рекомендую закладывать около 10% на подрезку.';

  @override
  String get aiEstimateAnswer =>
      'Могу помочь составить смету. Укажи площадь объекта и список работ или материалов — я помогу структурировать расчёт.';

  @override
  String get aiPaintAnswer =>
      'Для расчёта краски нужны площадь поверхности, количество слоёв и расход краски на 1 м².';

  @override
  String get aiWallpaperAnswer =>
      'Для расчёта обоев нужны размеры помещения, высота потолка, ширина рулона и длина рулона.';

  @override
  String get aiDefaultAnswer =>
      'Понял тебя 👍\n\nЯ могу помочь с расчётами материалов, сметами, ремонтом и организацией работ. Попробуй сформулировать задачу подробнее.';

  @override
  String get accountStatus => 'Статус аккаунта';
}
