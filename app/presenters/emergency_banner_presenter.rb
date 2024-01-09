class EmergencyBannerPresenter
  def initialize(current_banner)
    @current_banner = current_banner
  end

  def current_banner_rows
    [campaign_class_row] + other_rows
  end

private

  def campaign_class_row
    [
      {
        text: I18n.t("emergency_banner.keys.campaign_class"),
      },
      {
        text: I18n.t("emergency_banner.keys.campaign_classes.#{@current_banner[:campaign_class].underscore}"),
      },
    ]
  end

  def other_rows
    %i[heading short_description link link_text].map do |key|
      [
        {
          text: I18n.t("emergency_banner.keys.#{key}"),
        },
        {
          text: @current_banner[key],
        },
      ]
    end
  end
end
