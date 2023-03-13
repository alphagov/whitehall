module PublishingApi
  class HistoricalAccountsIndexPresenter
    attr_accessor :update_type

    HISTORY_OF_THE_UK_GOVERNMENT_CONTENT_ID = "db95a864-874f-4f50-a483-352a5bc7ba18".freeze

    def initialize(update_type: nil)
      self.update_type = update_type || "major"
    end

    def content_id
      "a258e45a-acbe-4d70-ad2c-a2a20761536a"
    end

    def content
      content = BaseItemPresenter.new(
        nil,
        title: "Past Prime Ministers",
        update_type:,
      ).base_attributes

      content.merge!(
        base_path:,
        details: {
          appointments_without_historical_accounts:,
        },
        document_type: "historic_appointments",
        public_updated_at: Time.zone.now,
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name: "historic_appointments",
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def appointments_without_historical_accounts
      role = Role.friendly.find("prime-minister")
      people_to_present = (role.role_appointments.historic.map(&:person) - HistoricalAccount.all.map(&:person)).uniq
      people_to_present.map do |person|
        { title: person.name,
          dates_in_office: person.previous_dates_in_office_for_role(role),
          image: {
            url: person.image_url,
            alt_text: person.name,
          } }
      end
    end

    def base_path
      "/government/history/past-prime-ministers"
    end

    def links
      {
        historical_accounts: HistoricalAccount.all.map(&:content_id),
        parent: [HISTORY_OF_THE_UK_GOVERNMENT_CONTENT_ID],
      }
    end
  end
end
