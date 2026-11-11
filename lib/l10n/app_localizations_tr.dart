// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Atmos';

  @override
  String get search => 'Ara';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get english => 'İngilizce';

  @override
  String get turkish => 'Türkçe';

  @override
  String get theme => 'Görünüm';

  @override
  String get system => 'Sistem';

  @override
  String get light => 'Açık';

  @override
  String get dark => 'Koyu';

  @override
  String get reduceMotion => 'Hareketi azalt';

  @override
  String get reduceMotionHint => 'Daha az animasyon kullan';

  @override
  String get favorites => 'Şehirleriniz';

  @override
  String get addCity => 'Şehir ekle';

  @override
  String get addFirstCity => 'Tahmini görmek için bir şehir ekleyin';

  @override
  String get searchHint => 'Şehir, bölge veya ülke arayın';

  @override
  String get searchPrompt => 'Şehir bulun';

  @override
  String get searching => 'Şehirler aranıyor…';

  @override
  String get noSearchResults => 'Şehir bulunamadı. Başka bir arama deneyin.';

  @override
  String get searchError =>
      'Şu anda arama yapılamıyor. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get addFavorite => 'Favorilere ekle';

  @override
  String removeFavorite(String city) {
    return '$city şehrini favorilerden kaldır';
  }

  @override
  String get cityAdded => 'Şehir favorilerinize eklendi';

  @override
  String get cityRemoved => 'Şehir favorilerinizden kaldırıldı';

  @override
  String get alreadyFavorite => 'Bu şehir zaten favorilerinizde';

  @override
  String get currentWeather => 'Anlık hava durumu';

  @override
  String get hourlyForecast => 'Saatlik tahmin';

  @override
  String get weekForecast => '7 günlük tahmin';

  @override
  String get today => 'Bugün';

  @override
  String get humidity => 'Nem';

  @override
  String get wind => 'Rüzgâr';

  @override
  String get precipitation => 'Yağış';

  @override
  String get feelsLike => 'Hissedilen';

  @override
  String get cachedWeather => 'Kayıtlı hava durumu · güncel olmayabilir';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get weatherUnavailable => 'Hava durumu şu anda alınamıyor.';

  @override
  String get weatherSetupError =>
      'Hava durumu hizmeti yapılandırılmamış. .env.example dosyasını .env olarak kopyalayıp WeatherAPI anahtarınızı ekleyin.';

  @override
  String get weatherAuthenticationError =>
      'WeatherAPI anahtarı kabul etmedi. .env yapılandırmanızı kontrol edin.';

  @override
  String get invalidCityError => 'Şehir bulunamadı. Başka bir konum deneyin.';

  @override
  String get weatherNetworkError =>
      'Hava durumu hizmetine ulaşılamıyor. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get weatherServiceError =>
      'Hava durumu hizmeti geçici olarak kullanılamıyor. Lütfen tekrar deneyin.';

  @override
  String get viewForecast => 'Ayrıntılı tahmin';

  @override
  String get noForecast => 'Tahmin ayrıntıları alınamıyor.';

  @override
  String updated(String time) {
    return 'Güncelleme: $time';
  }

  @override
  String get close => 'Kapat';

  @override
  String get systemMotion => 'Sistem hareket ayarları da dikkate alınır.';

  @override
  String get settingsSaveError =>
      'Ayarınız kaydedilemedi. Lütfen tekrar deneyin.';
}
