module PublishingApi
  class HistoricalAccountPresenter
    NUMBER_OF_RELATED_LINKS = 5

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
          dates_in_office: historical_account.person.previous_dates_in_office_for_role(historical_account.role),
          died: historical_account.died,
          interesting_facts: historical_account.interesting_facts,
          major_acts: historical_account.major_acts,
          political_party: historical_account.political_membership,
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
        ordered_related_items: related_pms,
      }
    end

    def related_pms
      role = Role.friendly.find("prime-minister")
      all_appointees = role
        .role_appointments
        .distinct(&:person)
        .order(:started_at)
        .map(&:person)

      person_to_present = historical_account.person

      neighbouring_role_holders(all_appointees, person_to_present).map do |person|
        {
          "title" => person.name,
          "base_path" => person.historical_accounts.present? ? person.historical_accounts.for_role(role.id).first.public_path : HistoricalAccountsIndexPresenter.base_path,
        }
      end
    end

    def neighbouring_role_holders(neighboring_people, person)
      person_index = neighboring_people.index(person)
      other_people = neighboring_people - [person]
      starting_index = person_index - 3

      if starting_index.negative?
        other_people.first(NUMBER_OF_RELATED_LINKS)
      elsif starting_index + NUMBER_OF_RELATED_LINKS >= neighboring_people.length
        other_people.last(NUMBER_OF_RELATED_LINKS)
      else
        other_people[starting_index...starting_index + NUMBER_OF_RELATED_LINKS]
      end
    end
  end
end
