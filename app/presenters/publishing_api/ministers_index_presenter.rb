module PublishingApi
  class MinistersIndexPresenter
    attr_accessor :update_type

    def initialize(update_type: nil)
      self.update_type = update_type || "major"
    end

    def content_id
      "324e4708-2285-40a0-b3aa-cb13af14ec5f"
    end

    def content
      content = BaseItemPresenter.new(
        nil,
        title: "Ministers",
        update_type:,
      ).base_attributes

      content.merge!(
        base_path:,
        details:,
        document_type: "ministers_index",
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "ministers_index",
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def links
      return {} if reshuffle_in_progress?

      {
        ordered_cabinet_ministers: ordered_cabinet_ministers_content_ids,
        ordered_also_attends_cabinet: ordered_also_attends_cabinet_content_ids,
        ordered_ministerial_departments: ordered_ministerial_departments_content_ids,
        ordered_house_of_commons_whips: ordered_whips_content_ids(Whitehall::WhipOrganisation::WhipsHouseOfCommons),
        ordered_junior_lords_of_the_treasury_whips: ordered_whips_content_ids(Whitehall::WhipOrganisation::JuniorLordsoftheTreasury),
        ordered_assistant_whips: ordered_whips_content_ids(Whitehall::WhipOrganisation::AssistantWhips),
        ordered_house_lords_whips: ordered_whips_content_ids(Whitehall::WhipOrganisation::WhipsHouseofLords),
        ordered_baronesses_and_lords_in_waiting_whips: ordered_whips_content_ids(Whitehall::WhipOrganisation::BaronessAndLordsInWaiting),
      }
    end

  private

    def details
      if reshuffle_in_progress?
        {
          reshuffle: { message: SitewideSetting.find_by(key: :minister_reshuffle_mode).govspeak },
        }
      else
        {
          body: "Read biographies and responsibilities of <a href=\"#cabinet-ministers\" class=\"govuk-link\">Cabinet ministers</a> and all <a href=\"#ministers-by-department\" class=\"govuk-link\">ministers by department</a>, as well as the <a href=\"#whips\" class=\"govuk-link\">whips</a> who help co-ordinate parliamentary business.",
        }
      end
    end

    def base_path
      "/government/ministers"
    end

    def reshuffle_in_progress?
      SitewideSetting.find_by(key: :minister_reshuffle_mode)&.on || false
    end

    def ordered_cabinet_ministers_content_ids
      ministers = MinisterialRole
        .cabinet
        .occupied
        .where(cabinet_member: true)
        .map(&:current_role_appointment)
        .map(&:person)
        .uniq

      sorted_ministers = ministers.sort_by do |person|
        [person.current_roles.map(&:seniority).min, person.sort_key]
      end

      sorted_ministers.map(&:content_id)
    end

    def ordered_also_attends_cabinet_content_ids
      ministers = MinisterialRole
      .also_attends_cabinet
      .occupied
      .map(&:current_role_appointment)
      .map(&:person)
      .uniq

      sorted_ministers = ministers.sort_by do |person|
        [person.current_roles.map(&:seniority).min, person.sort_key]
      end

      sorted_ministers.map(&:content_id)
    end

    def ordered_ministerial_departments_content_ids
      Organisation.ministerial_departments
        .excluding_govuk_status_closed
        .with_translations_for(:ministerial_roles)
        .includes(ministerial_roles: [:current_people])
        .order("organisations.ministerial_ordering, organisation_roles.ordering")
        .uniq
        .map(&:content_id)
    end

    def ordered_whips_content_ids(whip_type)
      Role
        .whip
        .where(whip_organisation_id: whip_type.id)
        .occupied
        .order(:whip_ordering)
        .map(&:current_role_appointment)
        .map(&:person)
        .map(&:content_id)
    end
  end
end
