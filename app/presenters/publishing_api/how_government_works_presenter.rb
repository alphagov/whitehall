module PublishingApi
  class HowGovernmentWorksPresenter
    attr_accessor :update_type

    def initialize(update_type: nil)
      self.update_type = update_type || "major"
    end

    def content_id
      "f56cfe74-8e5c-432d-bfcf-fd2521c5919c"
    end

    def content
      content = BaseItemPresenter.new(
        nil,
        title: "How government works",
        update_type:,
      ).base_attributes

      content.merge!(
        base_path:,
        description: "About the UK system of government. Understand who runs government, and how government is run.",
        document_type: "how_government_works",
        public_updated_at: Time.zone.now,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "how_government_works",
        details:,
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def base_path
      "/government/how-government-works"
    end

    def links
      return {} if reshuffle_in_progress?

      {
        current_prime_minister: [MinisterialRole.find_by(slug: "prime-minister")&.current_person&.content_id],
      }
    end

    def details
      if reshuffle_in_progress?
        {
          reshuffle_in_progress: reshuffle_in_progress?,
        }
      else
        {
          department_counts:,
          ministerial_role_counts:,
          reshuffle_in_progress: reshuffle_in_progress?,
        }
      end
    end

    def department_counts
      {
        ministerial_departments: Organisation.listable.ministerial_departments.count,
        non_ministerial_departments: Organisation.listable.non_ministerial_departments.count,
        agencies_and_public_bodies: Organisation.listable.select { |o| o.type.agency_or_public_body? }.count,
      }
    end

    def ministerial_role_counts
      {
        prime_minister:,
        cabinet_ministers:,
        other_ministers: total_ministers - cabinet_ministers - prime_minister,
        total_ministers:,
      }
    end

  private

    def reshuffle_in_progress?
      SitewideSetting.find_by(key: :minister_reshuffle_mode)&.on || false
    end

    def prime_minister
      1
    end

    def cabinet_ministers
      MinisterialRole.cabinet.occupied.where(cabinet_member: true).map(&:current_role_appointment).map(&:person).uniq.count
    end

    def total_ministers
      MinisterialRole.occupied.map(&:current_role_appointment).map(&:person).uniq.count
    end
  end
end
