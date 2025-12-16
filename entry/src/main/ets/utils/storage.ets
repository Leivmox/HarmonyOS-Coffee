//数据持久化存储
// 用户首选项为应用提供Key-Value键值型的数据处理能力，支持应用持久化轻量级数据，并对其修改和查询。
// 数据存储采用键值对形式，键为字符串类型，值可为数字、字符、布尔类型及其对应的数组。
// 用户首选项的持久化文件存储在preferencesDir路径下，创建preferences对象前，需要保证preferencesDir路径可读写。持久化文件存储路径中的加密等级会影响文件的可读写状态，路径访问限制详见应用文件目录与应用文件路径。
//导入 用户首选项 模块
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit';

let dataPreferences: preferences.Preferences | null = null;

/**
 * 获取 Preferences 实例
 * 增加 context 参数，允许从页面传入 Context，确保 100% 能拿到
 */
function getPrefs(context?: Context): preferences.Preferences {
  if (dataPreferences) {
    return dataPreferences;
  }
  // 如果没有传入 context，尝试获取全局 context，如果还获取不到，这一步会抛错提示
  let finalContext = context || getContext();
  let option: preferences.Options = { name: "myStorage" };
  dataPreferences = preferences.getPreferencesSync(finalContext, option);
  return dataPreferences;
}

// 获取数据 (允许传入 context)
function getStorage(key: string, context?: Context): preferences.ValueType {
  let prefs = getPrefs(context);
  let val = prefs.getSync(key, "");
  console.log(`[Storage] 读取 key=${key}, val=${val}`);
  return val;
}

// 保存数据 (允许传入 context)
function saveStorage(key: string, value: preferences.ValueType, context?: Context) {
  let prefs = getPrefs(context);
  prefs.putSync(key, value);
  prefs.flushSync();
  console.log(`[Storage] 保存 key=${key}, val=${value}`);
}

// 删除数据
function delStorage(key: string, context?: Context) {
  let prefs = getPrefs(context);
  prefs.deleteSync(key);
  prefs.flushSync();
}

// 清除所有
function clearStorage(context?: Context) {
  let prefs = getPrefs(context);
  prefs.clearSync();
  prefs.flushSync();
}

export { getStorage, saveStorage, delStorage, clearStorage }
