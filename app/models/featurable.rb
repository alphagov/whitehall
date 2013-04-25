module Featurable
  extend ActiveSupport::Concern

  included do
    has_many :feature_lists, as: :featurable, dependent: :destroy
  end

  def feature_list_for_locale(locale)
    feature_lists.find_by_locale(locale) || feature_lists.build(locale: locale)
  end
end
