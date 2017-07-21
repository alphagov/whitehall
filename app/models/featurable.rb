module Featurable
  extend ActiveSupport::Concern

  included do
    has_many :feature_lists, as: :featurable, dependent: :destroy
  end

  def feature_list_for_locale(locale)
    feature_lists.find_by(locale: locale) || feature_lists.build(locale: locale)
  end

  def load_or_create_feature_list(locale = nil)
    locale = I18n.default_locale if locale.blank?
    feature_lists.find_by(locale: locale) || feature_lists.create!(locale: locale)
  end
end
