class Admin::Editions::LanguageSelectFormControl < ViewComponent::Base
  delegate :options_for_locales, to: :helpers
  def initialize(edition)
    @edition = edition
  end

  def render?
    @edition.translatable?
  end
end
