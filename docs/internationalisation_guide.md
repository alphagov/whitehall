# Internationalisation guide

This is mostly standard [Rails i18n](http://guides.rubyonrails.org/i18n.html) - Translations are stored in `config/locales/`, with a `.yml` file per locale.

If translation value is missing from a locale file then the EN value will be used instead.

## Changing an existing translation key

Edit the value of EN locale, you should then _manually_ edit all other locales to set the altered translated value to be blank.

## Adding a new translation key

_Manually_ create the key in `en.yml`, with the english text.

Run a task to add that key to all other language files:

```
bundle exec rake translation:regenerate
```

### Pluralised translations

For terms that are translatable in both singular and plural forms (e.g. document.type.publication), include "one" and "other"
keys for the singular and plural translation of the term.

Note: pluralised translation terms should only ever contain these two plural form keys in en.yml, otherwise the code that
regenerates the other translation locale files will not recognise them as being plural translations and will not generate
the correct pluralisation keys for the different locales.

## Updating the locales files

There are rake tasks to export and import a CSV file of translations and keys
(provided by the [`rails_translation_manager`](https://github.com/alphagov/rails_translation_manager)
gem. These CSV files are exported, edited and then imported back as `.yml` files.

There's no timeline for how frequently this is done, so you can expect many translation values to be missing in non EN locales.


