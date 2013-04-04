#￼Inside Government i18n notes

These are notes about the i18n work. Some of this may have been superceded, but it's here for a reference in case it's useful.

## User experience

* Translation of editions (worldwide priorities, news articles and speeches)
* Translation of world locations
* Translation of worldwide organisations
* Translation of worldwide offices
* Translation of people biographies and roles
    * You’ll need the following translated before you can see such a person
by following links in the frontend:
        * World location
        * Worldwide organisation associated to the aforementioned World
location
        * Person
        * Worldwide role associated to the aforementioned Person and Worldwide organisation
* Revised Worldwide Location pages and their only showing content available in the language specified
* Fallback to English for missing template and content translations
    * We don’t currently enable fallbacks in development/test environments,
although this is up for discussion.

## General notes
* Ross provided us the list of locales from the FCO
* We only link to content that’s available in the selected locale, i.e. we don’t link
to a Spanish translation of a worldwide office if that office hasn’t had its details translated to Spanish.

## Technical

* Other solutions we rejected after experimentation
    * Attribute translation
        * James A did this in the [spiking-translated-attributes](https://github.com/alphagov/whitehall/compare/master...spiking-translated-attributes) branch
        * We felt that a translation should exist on its own in some sense.
    * Separate document translations
        * Tom spiked on this although the branch has been deleted.
        * If a translation needed to go through a separate workflow then
this would’ve made more sense. As it is, it’s unnecessarily
complex.
    * Multiple associated translations for a given document
        * James M and Chris spiked on this although the branch has been deleted.
        * This ended up being quite close to Globalize3 so we went down that route. There weren’t any massive advantages to using our own solution.
* The use of [Globalize3](https://github.com/svenfuchs/globalize3)
    * Globalize3 doesn’t really expect you to interact with the translations
independently. You should change locale and deal with the object-that-has-translations alone. Having said this, it’s worth noting that you can access attributes and objects in a specific locale if you really want.
    * Migration problems with removing columns - this isn’t specific to Globalize3 but came up when we first introduced it.
        * Commit [c30328](https://github.com/alphagov/whitehall/commit/c303284420524fa28ed3dfd1eaae426051c86368) should contain enough information to understand the problem.
    * One of the Globalize3 methods (`.with_translation`) will only return the records where the translation passes any validates_presence_of validations on the parent object. On Edition, it’ll only return translations where all of the title, summary and body are present, for example.
    * LocalisedModel
        * Use this when dealing with one model in multiple locales, for example in the admin interface where we want to show the English translation alongside a new translation.

    * TranslatableModel
        * Used to extend any translatable model such that they satisfy requirements of some templates/partials used to show translatable models. For example, displaying the links to switch between available translations.
    * Locale model
        * Rails i18n uses symbols, we want language names like "Français"
as well.
* The removal of PaperTrail - [PR 195](https://github.com/alphagov/whitehall/pull/195)
    * One of our original arguments for Globalize3 was that it apparently worked with papertrail. Unfortunately, it doesn’t work in the way we required. Globalize3 uses PaperTrail to record versions of the translations while we needed versions of the Editions.
* The use of the standard [Rails’ i18n framework](http://guides.rubyonrails.org/i18n.html) and [rails-i18n gem](https://github.com/svenfuchs/rails-i18n)
    * rails-i18n gem provides default translations for some locales for things
like dates, month names.
* Workflow for updating Rails’ i18n <locale>.yml files
    * translation key "scheme"
    * Issues around non-UTF-8 file CSV encodings
* The translation admin pattern
    * Only edit and update for translations. There can only be one translation for a given language for a given thing. The locale is the :id.
* ModelStubbingHelpers#stub_translatable_record adds extra necessary stubbing for “translation” association added by Globalize3.
    * Not using this for a model with translated attributes may result unexpected database queries and even a stack overflow error.
* The “translated” FactoryGirl trait and its “translate_into” option
    * Introduced/extended in [03f966](https://github.com/alphagov/whitehall/commit/03f966565abf3cda1ed494c4f87b9c0828d9b8fc).
    * Makes test set-up simpler as you don’t have to know how to add a
translation to an object.
    * `create(:world_location,translated_into:[:fr,:es,...])`
    * `create(:world_location,translated_into:{fr:{title:“Letitle”}, es:{... }})`
    * Slight gotcha when there are no translated attributes that are required. This means you cannot just use `FactoryGirl.create(:person, translated_into: [:fr])` and expect the person to have a translation. You have to do the more explicit `FactoryGirl.create(:person, translated_into: { fr: { biography: “biographie” } })`.
* Routing and the “non-golden” path
    * This is to support the desired URL pattern of
/path/to/resource[.<locale>][.<format>]
    * Monkey patching Rails routing so it’s possible, although hopefully
unlikely, this’ll cause problems in future (particularly when upgrading
Rails).
    * Added by Tom in [PR 260](https://github.com/alphagov/whitehall/pull/260). Enhanced by James A in [PR 268](https://github.com/alphagov/whitehall/pull/268) to make some
named route methods preserve locale as you move around the site.
* Right to Left languages
    * We use the i18n ‘meta’ key to store whether a language is RTL. This follows a Globalize3 convention.
    * Only applied to translated attribute input fields in admin (e.g. Whitehall::FormBuilder#translated_text_field)
    * Automatic stylesheet selection based on locale on public-facing pages.
    * Added by Tom in [PR 253](https://github.com/alphagov/whitehall/pull/253).
* The fact that we’re not storing any i18n content in Rummager and how this
affected how we approached the story to do with showing all News Articles, for example, in Spanish -- [Story 44634725](https://www.pivotaltracker.com/projects/367813#!/stories/44634725).
    * We’ve kept the MySQL document filter for this purpose.

* Editing World Location titles, e.g. “UK with Iran”
    * This was an example of where adding a translation to the <locale>.yml wouldn’t suffice and we needed to extend what was stored in the database.
￼￼￼￼
￼* The JavaScript dynamic relative times were removed (by Edd). There is still an example of non-translated javascript markup - ‘+ others’, or similar.
* Walkthrough adding a new locale
    * Is [PR 224](https://github.com/alphagov/whitehall/pull/224) a good example?

## Gotchas

* Concatenating translated strings where the translation is missing can cause you problems, as demonstrated in [Story 44102803](https://www.pivotaltracker.com/projects/367813#!/stories/44102803). The fixes for that story were in [43d57c](https://github.com/alphagov/whitehall/commit/43d57c), [a74c94](https://github.com/alphagov/whitehall/commit/a74c94) and [c527d3](https://github.com/alphagov/whitehall/commit/c527d3).
* We had to change the database to use UTF-8 by default. Apparently it was in a mixed state of Latin-1 and UTF-8. We believe this is now fixed for everything, for all time.
    * [PR210](https://github.com/alphagov/whitehall/pull/210)

## Improvements
* Requests for content in a language that we don’t have a translation for could return a 404 with a list of available translations.
* Admin CSV-to-YAML flow for adding translations. We need feedback before we can consider any improvements.

## Testing
* The use of GenericEditionsController to test shared functionality and avoid the proliferation of “macro” style tests.
* Explain the ‘new style’ of Cucumber scenarios.
￼￼￼￼￼￼