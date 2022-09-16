module Featurable
  extend ActiveSupport::Concern

  included do
    has_many :feature_lists, as: :featurable, dependent: :destroy do
      def build_for_locale(locale)
        target.detect(-> { build(locale:) }) { |fl| locale.match?(fl.locale) }
      end
    end
  end

  def feature_list_for_locale(locale)
    feature_lists.find_by(locale:) || feature_lists.build_for_locale(locale)
  end

  def load_or_create_feature_list(locale = nil)
    locale = I18n.default_locale if locale.blank?
    feature_lists.find_by(locale:) || feature_lists.create!(locale:)
  end

  def build_feature_list_for_locale(locale)
    feature_lists.target.select { |feature_list| feature_list.locale == locale }
  end
end
