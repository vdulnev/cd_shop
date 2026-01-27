import 'package:floor/floor.dart';

@Entity(tableName: 'app_settings')
class AppSettingsEntity {

  const AppSettingsEntity({
    required this.key,
    required this.value,
  });
  
  @primaryKey
  final String key;
  final String value;
}
