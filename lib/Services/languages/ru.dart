import 'languages.dart';

class LanguageRu extends Languages {
  @override
  String get welcomeToEasark => "ДОБРО ПОЖАЛОВАТЬ";
  @override
  String get labelSelectLanguage => "Русский";
  @override
  String get loginScreen1head => "Онлайн бронирование";
  @override
  String get loginScreen1text =>
      "Бронируйте онлайн без проблем. Больше нет нужды связываться с администраторами и вести долгую беседу";
  @override
  String get loginScreen2head => "2 минуты";
  @override
  String get loginScreen2text =>
      "Всего лишь 2 минуты чтобы забронировать услугу в любом месте";
  @override
  String get loginScreen3head => "Комфорт";
  @override
  String get loginScreen3text =>
      "Мы предлагаем удобное расписание и систему которая регулирует и организовывает ваши броны";
  @override
  String get getStarted => "Начнем";
  @override
  String get loginScreenYourPhone => "Телефон";
  @override
  String get loginScreen6Digits => "Минимум 6 символов";
  @override
  String get loginScreenEnterCode => "Введите код";
  @override
  String get loginScreenReenterPhone => "Поменять номер телефона";
  @override
  String get loginScreenPolicy => "Продолжая вы принимаете все правила пользования приложением и нашу Политику Конфиденциальности";
@override
  String get loginScreenCodeIsNotValid => "Время действия кода истекло";


  @override
  String get mapScreenSearchHere => "Искать близлежащие парковки";
}