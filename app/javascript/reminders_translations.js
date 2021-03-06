import { en } from "../../config/locales/views/reminders/en.yml"
import { en as defaults } from "../../config/locales/views/defaults/en.yml"

var locale = I18n.locale = window.current_locale;
if(typeof I18n.translations[locale] == 'undefined'){
  I18n.translations.en = {}
}
_.extend(I18n.translations.en, en)
_.extend(I18n.translations.en.reminders.reminder, defaults.defaults)


export default I18n;
