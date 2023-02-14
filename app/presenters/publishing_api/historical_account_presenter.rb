module PublishingApi
  class HistoricalAccountPresenter
    attr_accessor :historical_account, :update_type

    def initialize(historical_account, update_type: nil)
      self.historical_account = historical_account
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :historical_account

    def content
      content = BaseItemPresenter.new(
        historical_account,
        title: historical_account.person.name,
        update_type:,
      ).base_attributes

      content.merge!(
        description: historical_account.summary,
        details: {
          body: Whitehall::GovspeakRenderer.new.govspeak_to_html(historical_account.body),
          born: historical_account.born,
          died: historical_account.died,
          interesting_facts: historical_account.interesting_facts,
          major_acts: historical_account.major_acts,
          political_party: historical_account.political_membership,
          previous_dates_in_office: historical_account.previous_dates_in_office,
        },
        document_type: "historic_appointment",
        public_updated_at: historical_account.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "historic_appointment",
      )

      content.merge!(PayloadBuilder::PolymorphicPath.for(historical_account))
    end

    def links
      {
        person: [
          historical_account.person.content_id,
        ],
      }
    end
  end
end
