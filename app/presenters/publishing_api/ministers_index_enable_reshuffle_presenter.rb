module PublishingApi
  class MinistersIndexEnableReshufflePresenter < MinistersIndexPresenter
    def links
      {
        ordered_cabinet_ministers: [],
        ordered_also_attends_cabinet: [],
        ordered_ministerial_departments: [],
        ordered_house_of_commons_whips: [],
        ordered_junior_lords_of_the_treasury_whips: [],
        ordered_assistant_whips: [],
        ordered_house_lords_whips: [],
        ordered_baronesses_and_lords_in_waiting_whips: [],
      }
    end

  private

    def details
      {
        reshuffle: { message: bare_govspeak_to_html(SitewideSetting.find_by(key: :minister_reshuffle_mode).govspeak) },
      }
    end
  end
end
