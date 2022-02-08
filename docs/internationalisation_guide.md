# Internationalisation guide

This is mostly standard [Rails i18n](http://guides.rubyonrails.org/i18n.html):

- Translations are stored in `config/locales/`, with a `.yml` file per locale.
- If translation value is missing from a locale file then the EN value will be used instead.

## Changing an existing translation key

1. Edit the value of the EN locale
1. You then need to set the non-EN locale values to be blank. You can do this manually or follow the [rails_translation_manager documentation](https://github.com/alphagov/rails_translation_manager#i18n-tasks)

## Adding a new translation key

1. Manually create the key in `en.yml`, with the english text.
1. Then run `rake translation:add_missing` (see [rails_translation_manager documentation](https://github.com/alphagov/rails_translation_manager#rake-command-reference))

### Pluralised translations

For terms that are translatable in both singular and plural forms (e.g. document.type.publication), include "one" and "other"
keys for the singular and plural translation of the term.

Note: pluralised translation terms should only ever contain these two plural form keys in en.yml, otherwise the code that
regenerates the other translation locale files will not recognise them as being plural translations and will not generate
the correct pluralisation keys for the different locales.

## Updating the locales files

There are rake tasks to export and import a CSV file of translations and keys (provided by the [`rails_translation_manager`](https://github.com/alphagov/rails_translation_manager)
gem. These CSV files are exported, edited and then imported back as `.yml` files.

Translations were last [updated in bulk in November 2021](https://github.com/alphagov/whitehall/pull/6369). Over time, you can expect more and more translation values to be missing from non-EN locales when performing this update.
