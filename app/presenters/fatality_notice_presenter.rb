class FatalityNoticePresenter < Draper::Base
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  decorates :fatality_notice

  def display_date_attribute_name
    :published_at
  end
end
