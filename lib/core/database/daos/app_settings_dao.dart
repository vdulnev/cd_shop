import 'package:floor/floor.dart';

import 'package:cd_shop/core/database/entities/app_settings_entity.dart';

@dao
abstract class AppSettingsDao {
  @Query('SELECT * FROM app_settings WHERE key = :key')
  Future<AppSettingsEntity?> getSetting(String key);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSetting(AppSettingsEntity setting);

  @Query('DELETE FROM app_settings WHERE key = :key')
  Future<void> deleteSetting(String key);
}
