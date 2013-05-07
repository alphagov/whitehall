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
    include TranslatableModel

    translates :title, :summary, :body

    add_trait Trait

    scope :in_default_locale, joins(:translations).where("edition_translations.locale" => I18n.default_locale)
    validate :primary_locale_is_valid
  end

  def translatable?
    false
  end

  private

  def primary_locale_is_valid
    unless I18n.available_locales.include?(primary_locale.intern)
      errors.add(:primary_locale, 'is not a valid locale')
    end
  end
end
