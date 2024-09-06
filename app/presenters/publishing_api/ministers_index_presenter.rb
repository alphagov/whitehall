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
        title:,
        update_type:,
      ).base_attributes

      content.merge!(
        base_path:,
        description: "Read biographies and responsibilities of Cabinet ministers and all ministers by department, as well as the whips who help co-ordinate parliamentary business.",
        details:,
        document_type: "ministers_index",
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name: "ministers_index",
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def links
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

    def title
      "Ministers"
    end

    def base_path
      "/government/ministers"
    end

  private

    def details
      {
        body: "Read biographies and responsibilities of <a href=\"#cabinet-ministers\" class=\"govuk-link\">Cabinet ministers</a> and all <a href=\"#ministers-by-department\" class=\"govuk-link\">ministers by department</a>, as well as the <a href=\"#whips\" class=\"govuk-link\">whips</a> who help co-ordinate parliamentary business.",
      }
    end

    def ordered_cabinet_ministers_content_ids
      Person.joins(role_appointments: :role)
            .where(role_appointments: { ended_at: nil })
            .where(role: { type: "MinisterialRole", cabinet_member: true })
            .order("role.seniority")
            .distinct
            .pluck(:content_id)
    end

    def ordered_also_attends_cabinet_content_ids
      Person.joins(role_appointments: :role)
            .where(role_appointments: { ended_at: nil })
            .where(role: { type: "MinisterialRole" })
            .where("role.attends_cabinet_type_id IS NOT NULL")
            .order("role.seniority")
            .distinct
            .pluck(:content_id)
    end

    def ordered_ministerial_departments_content_ids
      Organisation.ministerial_departments
        .joins(:ministerial_roles)
        .excluding_govuk_status_closed
        .order("organisations.ministerial_ordering, organisation_roles.ordering")
        .distinct
        .pluck(:content_id)
    end

    def ordered_whips_content_ids(whip_type)
      Person.joins(role_appointments: :role)
            .where(role: { whip_organisation_id: whip_type.id })
            .where(role_appointments: { ended_at: nil })
            .order("role.whip_ordering")
            .distinct
            .pluck(:content_id)
    end
  end
end
