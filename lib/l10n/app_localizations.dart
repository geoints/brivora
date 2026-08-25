import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'Brivora'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get home;

  /// No description provided for @projects.
  ///
  /// In ru, this message translates to:
  /// **'Проекты'**
  String get projects;

  /// No description provided for @ai.
  ///
  /// In ru, this message translates to:
  /// **'ИИ'**
  String get ai;

  /// No description provided for @profile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @russian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @kazakh.
  ///
  /// In ru, this message translates to:
  /// **'Қазақша'**
  String get kazakh;

  /// No description provided for @recentProjects.
  ///
  /// In ru, this message translates to:
  /// **'Недавние проекты'**
  String get recentProjects;

  /// No description provided for @noRecentProjects.
  ///
  /// In ru, this message translates to:
  /// **'Нет недавних проектов'**
  String get noRecentProjects;

  /// No description provided for @tasks.
  ///
  /// In ru, this message translates to:
  /// **'Задачи'**
  String get tasks;

  /// No description provided for @notes.
  ///
  /// In ru, this message translates to:
  /// **'Заметки'**
  String get notes;

  /// No description provided for @photos.
  ///
  /// In ru, this message translates to:
  /// **'Фото'**
  String get photos;

  /// No description provided for @estimate.
  ///
  /// In ru, this message translates to:
  /// **'Смета'**
  String get estimate;

  /// No description provided for @calculators.
  ///
  /// In ru, this message translates to:
  /// **'Калькуляторы'**
  String get calculators;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @create.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get create;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @darkTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная тема'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In ru, this message translates to:
  /// **'Светлая тема'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get systemTheme;

  /// No description provided for @loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get loading;

  /// No description provided for @quickActions.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые действия'**
  String get quickActions;

  /// No description provided for @welcome.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать'**
  String get welcome;

  /// No description provided for @helloUser.
  ///
  /// In ru, this message translates to:
  /// **'Здравствуйте, {name}'**
  String helloUser(String name);

  /// No description provided for @projectsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Управляйте своими проектами в одном месте'**
  String get projectsDescription;

  /// No description provided for @noProjects.
  ///
  /// In ru, this message translates to:
  /// **'У вас пока нет проектов'**
  String get noProjects;

  /// No description provided for @createFirstProject.
  ///
  /// In ru, this message translates to:
  /// **'Создайте свой первый проект'**
  String get createFirstProject;

  /// No description provided for @projectsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count}'**
  String projectsCount(int count);

  /// No description provided for @completed.
  ///
  /// In ru, this message translates to:
  /// **'Завершено'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In ru, this message translates to:
  /// **'В работе'**
  String get inProgress;

  /// No description provided for @overview.
  ///
  /// In ru, this message translates to:
  /// **'Обзор'**
  String get overview;

  /// No description provided for @noRecentProjectsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет недавних проектов'**
  String get noRecentProjectsTitle;

  /// No description provided for @noRecentProjectsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте проект, чтобы он появился здесь'**
  String get noRecentProjectsSubtitle;

  /// No description provided for @all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all;

  /// No description provided for @newProject.
  ///
  /// In ru, this message translates to:
  /// **'Новый проект'**
  String get newProject;

  /// No description provided for @newProjectShort.
  ///
  /// In ru, this message translates to:
  /// **'Новый'**
  String get newProjectShort;

  /// No description provided for @createProject.
  ///
  /// In ru, this message translates to:
  /// **'Создать проект'**
  String get createProject;

  /// No description provided for @materials.
  ///
  /// In ru, this message translates to:
  /// **'Материалы'**
  String get materials;

  /// No description provided for @untitled.
  ///
  /// In ru, this message translates to:
  /// **'Без названия'**
  String get untitled;

  /// No description provided for @progress.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс'**
  String get progress;

  /// No description provided for @statusCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Завершён'**
  String get statusCompleted;

  /// No description provided for @statusPlanning.
  ///
  /// In ru, this message translates to:
  /// **'Планирование'**
  String get statusPlanning;

  /// No description provided for @statusArchived.
  ///
  /// In ru, this message translates to:
  /// **'Архивирован'**
  String get statusArchived;

  /// No description provided for @statusActive.
  ///
  /// In ru, this message translates to:
  /// **'Активен'**
  String get statusActive;

  /// No description provided for @openedRecently.
  ///
  /// In ru, this message translates to:
  /// **'Открыт недавно'**
  String get openedRecently;

  /// No description provided for @openedJustNow.
  ///
  /// In ru, this message translates to:
  /// **'Открыт только что'**
  String get openedJustNow;

  /// No description provided for @openedMinutesAgo.
  ///
  /// In ru, this message translates to:
  /// **'Открыт {count} мин. назад'**
  String openedMinutesAgo(int count);

  /// No description provided for @openedHoursAgo.
  ///
  /// In ru, this message translates to:
  /// **'Открыт {count} ч. назад'**
  String openedHoursAgo(int count);

  /// No description provided for @openedYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Открыт вчера'**
  String get openedYesterday;

  /// No description provided for @openedDaysAgo.
  ///
  /// In ru, this message translates to:
  /// **'Открыт {count} дн. назад'**
  String openedDaysAgo(int count);

  /// No description provided for @openedDate.
  ///
  /// In ru, this message translates to:
  /// **'Открыт {date}'**
  String openedDate(String date);

  /// No description provided for @updatedJustNow.
  ///
  /// In ru, this message translates to:
  /// **'Обновлён только что'**
  String get updatedJustNow;

  /// No description provided for @updatedMinutesAgo.
  ///
  /// In ru, this message translates to:
  /// **'Обновлён {count} мин. назад'**
  String updatedMinutesAgo(int count);

  /// No description provided for @updatedHoursAgo.
  ///
  /// In ru, this message translates to:
  /// **'Обновлён {count} ч. назад'**
  String updatedHoursAgo(int count);

  /// No description provided for @updatedYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Обновлён вчера'**
  String get updatedYesterday;

  /// No description provided for @updatedDaysAgo.
  ///
  /// In ru, this message translates to:
  /// **'Обновлён {count} дн. назад'**
  String updatedDaysAgo(int count);

  /// No description provided for @updatedDate.
  ///
  /// In ru, this message translates to:
  /// **'Обновлён {date}'**
  String updatedDate(String date);

  /// No description provided for @newestProjects.
  ///
  /// In ru, this message translates to:
  /// **'Новые'**
  String get newestProjects;

  /// No description provided for @oldestProjects.
  ///
  /// In ru, this message translates to:
  /// **'Старые'**
  String get oldestProjects;

  /// No description provided for @nameAscending.
  ///
  /// In ru, this message translates to:
  /// **'Название А–Я'**
  String get nameAscending;

  /// No description provided for @nameDescending.
  ///
  /// In ru, this message translates to:
  /// **'Название Я–А'**
  String get nameDescending;

  /// No description provided for @shownProjects.
  ///
  /// In ru, this message translates to:
  /// **'Показано проектов: {count}'**
  String shownProjects(int count);

  /// No description provided for @projectsManagementDescription.
  ///
  /// In ru, this message translates to:
  /// **'Управляйте строительными проектами'**
  String get projectsManagementDescription;

  /// No description provided for @searchProjects.
  ///
  /// In ru, this message translates to:
  /// **'Поиск проектов...'**
  String get searchProjects;

  /// No description provided for @activeProjectsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Активные'**
  String get activeProjectsLabel;

  /// No description provided for @planningProjectsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Планирование'**
  String get planningProjectsLabel;

  /// No description provided for @completedProjectsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Завершённые'**
  String get completedProjectsLabel;

  /// No description provided for @projectsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить проекты'**
  String get projectsLoadError;

  /// No description provided for @nothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get nothingFound;

  /// No description provided for @noProjectsYet.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет проектов'**
  String get noProjectsYet;

  /// No description provided for @changeSearchOrFilter.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить поиск или фильтр.'**
  String get changeSearchOrFilter;

  /// No description provided for @createFirstProjectDescription.
  ///
  /// In ru, this message translates to:
  /// **'Создайте первый проект, чтобы начать работу.'**
  String get createFirstProjectDescription;

  /// No description provided for @projectCreated.
  ///
  /// In ru, this message translates to:
  /// **'Проект «{title}» создан'**
  String projectCreated(String title);

  /// No description provided for @registration.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registration;

  /// No description provided for @createAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get createAccount;

  /// No description provided for @createAccountDescription.
  ///
  /// In ru, this message translates to:
  /// **'Создайте аккаунт, чтобы пользоваться Brivora'**
  String get createAccountDescription;

  /// No description provided for @fullName.
  ///
  /// In ru, this message translates to:
  /// **'Полное имя'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите ваше полное имя'**
  String get fullNameHint;

  /// No description provided for @enterName.
  ///
  /// In ru, this message translates to:
  /// **'Введите имя'**
  String get enterName;

  /// No description provided for @nameMinLength.
  ///
  /// In ru, this message translates to:
  /// **'Имя должно содержать минимум 2 символа'**
  String get nameMinLength;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите электронную почту'**
  String get emailHint;

  /// No description provided for @enterEmail.
  ///
  /// In ru, this message translates to:
  /// **'Введите электронную почту'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный адрес электронной почты'**
  String get invalidEmail;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get passwordHint;

  /// No description provided for @enterPassword.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать минимум 6 символов'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите пароль'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль ещё раз'**
  String get confirmPasswordHint;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите пароль'**
  String get confirmPasswordRequired;

  /// No description provided for @agreeToTerms.
  ///
  /// In ru, this message translates to:
  /// **'Я принимаю'**
  String get agreeToTerms;

  /// No description provided for @termsOfUse.
  ///
  /// In ru, this message translates to:
  /// **'условия использования'**
  String get termsOfUse;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get passwordsDoNotMatch;

  /// No description provided for @register.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт?'**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get login;

  /// No description provided for @genericError.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка'**
  String get genericError;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In ru, this message translates to:
  /// **'Эта электронная почта уже используется'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль слишком простой'**
  String get weakPassword;

  /// No description provided for @invalidEmailAuth.
  ///
  /// In ru, this message translates to:
  /// **'Некорректный адрес электронной почты'**
  String get invalidEmailAuth;

  /// No description provided for @registrationError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось зарегистрировать аккаунт'**
  String get registrationError;

  /// No description provided for @addName.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте имя'**
  String get addName;

  /// No description provided for @addRoleAndCompany.
  ///
  /// In ru, this message translates to:
  /// **'Укажите должность и компанию'**
  String get addRoleAndCompany;

  /// No description provided for @chooseFromGallery.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать из галереи'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Сделать фото'**
  String get takePhoto;

  /// No description provided for @deletePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Удалить фотографию'**
  String get deletePhoto;

  /// No description provided for @avatarUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Аватар успешно обновлён'**
  String get avatarUpdated;

  /// No description provided for @avatarUploadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить аватар: {error}'**
  String avatarUploadError(String error);

  /// No description provided for @avatarDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Аватар удалён'**
  String get avatarDeleted;

  /// No description provided for @avatarDeleteError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить аватар: {error}'**
  String avatarDeleteError(String error);

  /// No description provided for @profileData.
  ///
  /// In ru, this message translates to:
  /// **'Данные профиля'**
  String get profileData;

  /// No description provided for @firstName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия'**
  String get lastName;

  /// No description provided for @position.
  ///
  /// In ru, this message translates to:
  /// **'Должность'**
  String get position;

  /// No description provided for @positionExample.
  ///
  /// In ru, this message translates to:
  /// **'Например: Прораб'**
  String get positionExample;

  /// No description provided for @company.
  ///
  /// In ru, this message translates to:
  /// **'Компания'**
  String get company;

  /// No description provided for @companyExample.
  ///
  /// In ru, this message translates to:
  /// **'Например: ИП Иванов И.И.'**
  String get companyExample;

  /// No description provided for @saveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить: {error}'**
  String saveError(String error);

  /// No description provided for @photosCount.
  ///
  /// In ru, this message translates to:
  /// **'{count}'**
  String photosCount(int count);

  /// No description provided for @activeProjects.
  ///
  /// In ru, this message translates to:
  /// **'{count}'**
  String activeProjects(int count);

  /// No description provided for @settingsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки приложения'**
  String get settingsSubtitle;

  /// No description provided for @proSubscription.
  ///
  /// In ru, this message translates to:
  /// **'Pro-подписка'**
  String get proSubscription;

  /// No description provided for @comingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get comingSoon;

  /// No description provided for @security.
  ///
  /// In ru, this message translates to:
  /// **'Безопасность'**
  String get security;

  /// No description provided for @securitySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Защита аккаунта и данных'**
  String get securitySubtitle;

  /// No description provided for @feedback.
  ///
  /// In ru, this message translates to:
  /// **'Обратная связь'**
  String get feedback;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Помогите улучшить Brivora'**
  String get feedbackSubtitle;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @version.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get version;

  /// No description provided for @logoutQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта?'**
  String get logoutQuestion;

  /// No description provided for @logoutConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Вы действительно хотите выйти?'**
  String get logoutConfirmation;

  /// No description provided for @logoutError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выйти: {error}'**
  String logoutError(String error);

  /// No description provided for @featureComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'{feature} — скоро будет доступно'**
  String featureComingSoon(String feature);

  /// No description provided for @aiAssistant.
  ///
  /// In ru, this message translates to:
  /// **'ИИ-помощник'**
  String get aiAssistant;

  /// No description provided for @online.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн'**
  String get online;

  /// No description provided for @aiWhatCanIDo.
  ///
  /// In ru, this message translates to:
  /// **'Что я могу сделать?'**
  String get aiWhatCanIDo;

  /// No description provided for @aiWelcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чем могу помочь?'**
  String get aiWelcomeTitle;

  /// No description provided for @aiWelcomeDescription.
  ///
  /// In ru, this message translates to:
  /// **'Спроси меня о ремонте, материалах, расчётах или создании сметы.'**
  String get aiWelcomeDescription;

  /// No description provided for @aiCalculateMaterial.
  ///
  /// In ru, this message translates to:
  /// **'Рассчитать материал'**
  String get aiCalculateMaterial;

  /// No description provided for @aiCalculateMaterialSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Плитка, краска, обои'**
  String get aiCalculateMaterialSubtitle;

  /// No description provided for @aiCreateEstimate.
  ///
  /// In ru, this message translates to:
  /// **'Создать смету'**
  String get aiCreateEstimate;

  /// No description provided for @aiCreateEstimateSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Быстро составить расчёт'**
  String get aiCreateEstimateSubtitle;

  /// No description provided for @aiAnalyzePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Анализ фото'**
  String get aiAnalyzePhoto;

  /// No description provided for @aiAnalyzePhotoSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Найти проблемы на объекте'**
  String get aiAnalyzePhotoSubtitle;

  /// No description provided for @aiRepairAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Совет по ремонту'**
  String get aiRepairAdvice;

  /// No description provided for @aiRepairAdviceSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Получить рекомендацию'**
  String get aiRepairAdviceSubtitle;

  /// No description provided for @aiExampleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: «Сколько плитки нужно для ванной 3×2 м?»'**
  String get aiExampleHint;

  /// No description provided for @aiMessageHint.
  ///
  /// In ru, this message translates to:
  /// **'Напиши сообщение...'**
  String get aiMessageHint;

  /// No description provided for @aiTileAnswer.
  ///
  /// In ru, this message translates to:
  /// **'Конечно. Для расчёта плитки мне понадобятся размеры помещения, размер одной плитки и желаемый запас. Обычно рекомендую закладывать около 10% на подрезку.'**
  String get aiTileAnswer;

  /// No description provided for @aiEstimateAnswer.
  ///
  /// In ru, this message translates to:
  /// **'Могу помочь составить смету. Укажи площадь объекта и список работ или материалов — я помогу структурировать расчёт.'**
  String get aiEstimateAnswer;

  /// No description provided for @aiPaintAnswer.
  ///
  /// In ru, this message translates to:
  /// **'Для расчёта краски нужны площадь поверхности, количество слоёв и расход краски на 1 м².'**
  String get aiPaintAnswer;

  /// No description provided for @aiWallpaperAnswer.
  ///
  /// In ru, this message translates to:
  /// **'Для расчёта обоев нужны размеры помещения, высота потолка, ширина рулона и длина рулона.'**
  String get aiWallpaperAnswer;

  /// No description provided for @aiDefaultAnswer.
  ///
  /// In ru, this message translates to:
  /// **'Понял тебя 👍\n\nЯ могу помочь с расчётами материалов, сметами, ремонтом и организацией работ. Попробуй сформулировать задачу подробнее.'**
  String get aiDefaultAnswer;

  /// No description provided for @accountStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус аккаунта'**
  String get accountStatus;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
