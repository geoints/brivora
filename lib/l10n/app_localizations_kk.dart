// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'Brivora';

  @override
  String get home => 'Басты бет';

  @override
  String get projects => 'Жобалар';

  @override
  String get ai => 'ЖИ';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Баптаулар';

  @override
  String get appearance => 'Безендіру';

  @override
  String get language => 'Тіл';

  @override
  String get russian => 'Русский';

  @override
  String get kazakh => 'Қазақша';

  @override
  String get recentProjects => 'Соңғы жобалар';

  @override
  String get noRecentProjects => 'Соңғы жобалар жоқ';

  @override
  String get tasks => 'Тапсырмалар';

  @override
  String get notes => 'Жазбалар';

  @override
  String get photos => 'Фотолар';

  @override
  String get estimate => 'Смета';

  @override
  String get calculators => 'Калькуляторлар';

  @override
  String get notifications => 'Хабарландырулар';

  @override
  String get save => 'Сақтау';

  @override
  String get cancel => 'Бас тарту';

  @override
  String get delete => 'Жою';

  @override
  String get edit => 'Өзгерту';

  @override
  String get close => 'Жабу';

  @override
  String get back => 'Артқа';

  @override
  String get add => 'Қосу';

  @override
  String get done => 'Дайын';

  @override
  String get create => 'Жасау';

  @override
  String get reset => 'Қалпына келтіру';

  @override
  String get retry => 'Қайталап көру';

  @override
  String get darkTheme => 'Қараңғы тақырып';

  @override
  String get lightTheme => 'Жарық тақырып';

  @override
  String get systemTheme => 'Жүйе бойынша';

  @override
  String get loading => 'Жүктелуде...';

  @override
  String get quickActions => 'Жылдам әрекеттер';

  @override
  String get welcome => 'Қош келдіңіз';

  @override
  String helloUser(String name) {
    return 'Сәлеметсіз бе, $name';
  }

  @override
  String get projectsDescription => 'Жобаларыңызды бір жерде басқарыңыз';

  @override
  String get noProjects => 'Сізде әзірге жобалар жоқ';

  @override
  String get createFirstProject => 'Алғашқы жобаңызды жасаңыз';

  @override
  String projectsCount(int count) {
    return '$count';
  }

  @override
  String get completed => 'Аяқталды';

  @override
  String get inProgress => 'Жұмыста';

  @override
  String get overview => 'Шолу';

  @override
  String get noRecentProjectsTitle => 'Соңғы жобалар жоқ';

  @override
  String get noRecentProjectsSubtitle => 'Осы жерден көру үшін жоба жасаңыз';

  @override
  String get all => 'Барлығы';

  @override
  String get newProject => 'Жаңа жоба';

  @override
  String get newProjectShort => 'Жаңа';

  @override
  String get createProject => 'Жоба жасау';

  @override
  String get materials => 'Материалдар';

  @override
  String get untitled => 'Атаусыз';

  @override
  String get progress => 'Прогресс';

  @override
  String get statusCompleted => 'Аяқталған';

  @override
  String get statusPlanning => 'Жоспарлау';

  @override
  String get statusArchived => 'Мұрағатталған';

  @override
  String get statusActive => 'Белсенді';

  @override
  String get openedRecently => 'Жақында ашылды';

  @override
  String get openedJustNow => 'Жаңа ғана ашылды';

  @override
  String openedMinutesAgo(int count) {
    return '$count мин. бұрын ашылды';
  }

  @override
  String openedHoursAgo(int count) {
    return '$count сағ. бұрын ашылды';
  }

  @override
  String get openedYesterday => 'Кеше ашылды';

  @override
  String openedDaysAgo(int count) {
    return '$count күн бұрын ашылды';
  }

  @override
  String openedDate(String date) {
    return '$date ашылды';
  }

  @override
  String get updatedJustNow => 'Жаңа ғана жаңартылды';

  @override
  String updatedMinutesAgo(int count) {
    return '$count мин. бұрын жаңартылды';
  }

  @override
  String updatedHoursAgo(int count) {
    return '$count сағ. бұрын жаңартылды';
  }

  @override
  String get updatedYesterday => 'Кеше жаңартылды';

  @override
  String updatedDaysAgo(int count) {
    return '$count күн бұрын жаңартылды';
  }

  @override
  String updatedDate(String date) {
    return '$date жаңартылды';
  }

  @override
  String get newestProjects => 'Жаңалары';

  @override
  String get oldestProjects => 'Ескілері';

  @override
  String get nameAscending => 'Атауы А–Я';

  @override
  String get nameDescending => 'Атауы Я–А';

  @override
  String shownProjects(int count) {
    return 'Көрсетілген жобалар: $count';
  }

  @override
  String get projectsManagementDescription => 'Құрылыс жобаларын басқарыңыз';

  @override
  String get searchProjects => 'Жобаларды іздеу...';

  @override
  String get activeProjectsLabel => 'Белсенді';

  @override
  String get planningProjectsLabel => 'Жоспарлау';

  @override
  String get completedProjectsLabel => 'Аяқталған';

  @override
  String get projectsLoadError => 'Жобаларды жүктеу мүмкін болмады';

  @override
  String get nothingFound => 'Ештеңе табылмады';

  @override
  String get noProjectsYet => 'Әзірге жобалар жоқ';

  @override
  String get changeSearchOrFilter =>
      'Іздеу немесе сүзгі параметрлерін өзгертіп көріңіз.';

  @override
  String get createFirstProjectDescription =>
      'Жұмысты бастау үшін алғашқы жобаңызды жасаңыз.';

  @override
  String projectCreated(String title) {
    return '«$title» жобасы жасалды';
  }

  @override
  String get registration => 'Тіркелу';

  @override
  String get createAccount => 'Аккаунт жасау';

  @override
  String get createAccountDescription => 'Brivora қолдану үшін аккаунт жасаңыз';

  @override
  String get fullName => 'Толық аты-жөні';

  @override
  String get fullNameHint => 'Толық аты-жөніңізді енгізіңіз';

  @override
  String get enterName => 'Атыңызды енгізіңіз';

  @override
  String get nameMinLength => 'Аты кемінде 2 таңбадан тұруы керек';

  @override
  String get email => 'Электрондық пошта';

  @override
  String get emailHint => 'Электрондық поштаңызды енгізіңіз';

  @override
  String get enterEmail => 'Электрондық поштаңызды енгізіңіз';

  @override
  String get invalidEmail => 'Дұрыс электрондық пошта мекенжайын енгізіңіз';

  @override
  String get password => 'Құпиясөз';

  @override
  String get passwordHint => 'Құпиясөзіңізді енгізіңіз';

  @override
  String get enterPassword => 'Құпиясөзді енгізіңіз';

  @override
  String get passwordMinLength => 'Құпиясөз кемінде 6 таңбадан тұруы керек';

  @override
  String get confirmPassword => 'Құпиясөзді растаңыз';

  @override
  String get confirmPasswordHint => 'Құпиясөзді қайта енгізіңіз';

  @override
  String get confirmPasswordRequired => 'Құпиясөзді растаңыз';

  @override
  String get agreeToTerms => 'Мен қабылдаймын';

  @override
  String get termsOfUse => 'пайдалану шарттарын';

  @override
  String get passwordsDoNotMatch => 'Құпиясөздер сәйкес келмейді';

  @override
  String get register => 'Тіркелу';

  @override
  String get alreadyHaveAccount => 'Аккаунтыңыз бар ма?';

  @override
  String get login => 'Кіру';

  @override
  String get genericError => 'Қате орын алды';

  @override
  String get emailAlreadyInUse => 'Бұл электрондық пошта бұрыннан қолданылуда';

  @override
  String get weakPassword => 'Құпиясөз тым әлсіз';

  @override
  String get invalidEmailAuth => 'Электрондық пошта мекенжайы дұрыс емес';

  @override
  String get registrationError => 'Аккаунтты тіркеу мүмкін болмады';

  @override
  String get addName => 'Атыңызды қосыңыз';

  @override
  String get addRoleAndCompany => 'Лауазымыңыз бен компанияңызды көрсетіңіз';

  @override
  String get chooseFromGallery => 'Галереядан таңдау';

  @override
  String get takePhoto => 'Фото түсіру';

  @override
  String get deletePhoto => 'Фотосуретті жою';

  @override
  String get avatarUpdated => 'Аватар сәтті жаңартылды';

  @override
  String avatarUploadError(String error) {
    return 'Аватарды жүктеу мүмкін болмады: $error';
  }

  @override
  String get avatarDeleted => 'Аватар жойылды';

  @override
  String avatarDeleteError(String error) {
    return 'Аватарды жою мүмкін болмады: $error';
  }

  @override
  String get profileData => 'Профиль деректері';

  @override
  String get firstName => 'Аты';

  @override
  String get lastName => 'Тегі';

  @override
  String get position => 'Лауазымы';

  @override
  String get positionExample => 'Мысалы: Бригадир';

  @override
  String get company => 'Компания';

  @override
  String get companyExample => 'Мысалы: ЖК Иванов И.И.';

  @override
  String saveError(String error) {
    return 'Сақтау мүмкін болмады: $error';
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
  String get settingsSubtitle => 'Қолданба баптаулары';

  @override
  String get proSubscription => 'Pro жазылымы';

  @override
  String get comingSoon => 'Жақында';

  @override
  String get security => 'Қауіпсіздік';

  @override
  String get securitySubtitle => 'Аккаунт пен деректерді қорғау';

  @override
  String get feedback => 'Кері байланыс';

  @override
  String get feedbackSubtitle => 'Brivora-ны жақсартуға көмектесіңіз';

  @override
  String get logout => 'Шығу';

  @override
  String get version => 'Нұсқа';

  @override
  String get logoutQuestion => 'Аккаунттан шығу керек пе?';

  @override
  String get logoutConfirmation => 'Шынымен аккаунттан шыққыңыз келе ме?';

  @override
  String logoutError(String error) {
    return 'Шығу мүмкін болмады: $error';
  }

  @override
  String featureComingSoon(String feature) {
    return '$feature — жақында қолжетімді болады';
  }

  @override
  String get aiAssistant => 'ЖИ көмекшісі';

  @override
  String get online => 'Онлайн';

  @override
  String get aiWhatCanIDo => 'Мен не істей аламын?';

  @override
  String get aiWelcomeTitle => 'Қалай көмектесе аламын?';

  @override
  String get aiWelcomeDescription =>
      'Жөндеу, материалдар, есептеулер немесе смета жасау туралы сұраңыз.';

  @override
  String get aiCalculateMaterial => 'Материалды есептеу';

  @override
  String get aiCalculateMaterialSubtitle => 'Плитка, бояу, тұсқағаз';

  @override
  String get aiCreateEstimate => 'Смета жасау';

  @override
  String get aiCreateEstimateSubtitle => 'Есепті жылдам құрастыру';

  @override
  String get aiAnalyzePhoto => 'Фотоны талдау';

  @override
  String get aiAnalyzePhotoSubtitle => 'Нысандағы мәселелерді табу';

  @override
  String get aiRepairAdvice => 'Жөндеу бойынша кеңес';

  @override
  String get aiRepairAdviceSubtitle => 'Ұсыныс алу';

  @override
  String get aiExampleHint => 'Мысалы: «3×2 м ваннаға қанша плитка қажет?»';

  @override
  String get aiMessageHint => 'Хабарлама жазыңыз...';

  @override
  String get aiTileAnswer =>
      'Әрине. Плитканы есептеу үшін бөлменің өлшемдері, бір плитканың өлшемі және қажетті қор мөлшері керек. Әдетте кесуге шамамен 10% қор қосуды ұсынамын.';

  @override
  String get aiEstimateAnswer =>
      'Смета жасауға көмектесе аламын. Нысанның ауданын және жұмыс немесе материалдар тізімін көрсетіңіз — есепті құрылымдауға көмектесемін.';

  @override
  String get aiPaintAnswer =>
      'Бояу мөлшерін есептеу үшін бетінің ауданы, қабат саны және 1 м²-ге кететін бояу шығыны қажет.';

  @override
  String get aiWallpaperAnswer =>
      'Тұсқағазды есептеу үшін бөлменің өлшемдері, төбенің биіктігі, орамның ені мен ұзындығы қажет.';

  @override
  String get aiDefaultAnswer =>
      'Түсіндім 👍\n\nМатериалдарды есептеуге, смета жасауға, жөндеу және жұмыстарды ұйымдастыруға көмектесе аламын. Тапсырманы толығырақ сипаттап көріңіз.';

  @override
  String get accountStatus => 'Аккаунт күйі';
}
