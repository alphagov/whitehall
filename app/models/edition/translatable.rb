module Edition::Translatable
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.translations.each do |translation|
        I18n.with_locale(translation.locale) do
          edition.title = @edition.title
          edition.summary = @edition.summary
          edition.body = @edition.body
        end
      end
    end
  end

  included do
    translates :title, :summary, :body
    include ::Translatable

    add_trait Trait

    scope :in_default_locale, joins(:translations).where("edition_translations.locale" => I18n.default_locale)
  end

  def non_english_translations
    translations.where(["locale != ?", I18n.default_locale])
  end

  def available_in_multiple_languages?
    translated_locales.length > 1
  end

  def translatable?
    false
  end
end
