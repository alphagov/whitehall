module Whitehall::Uploader
  class SpeechRow < Row
    def self.validator
      super
        .ignored("ignore_*")
        .required("type")
        .multiple("policy_#", 0..4)
        .required(%w{delivered_by delivered_on event_and_location})
        .multiple("country_#", 0..4)
        .translatable(%w{title summary body})
        .multiple("topic_#", 0..4)
    end

    def speech_type
      Finders::SpeechTypeFinder.find(row['type'], @logger, @line_number)
    end

    def role_appointment
      if delivered_on.blank?
        @logger.warn(%{Discarding delivered_by information "#{row['delivered_by']}" because delivered_on is missing}, @line_number)
        nil
      else
        Finders::RoleAppointmentsFinder.find(delivered_on, row['delivered_by'], @logger, @line_number).first
      end
    end

    def related_editions
      Finders::EditionFinder.new(Policy, @logger, @line_number).find(row['policy_1'], row['policy_2'], row['policy_3'], row["policy_4"])
    end

    def location
      row['event_and_location']
    end

    def first_published_at
      delivered_on
    end

    def delivered_on
      Parsers::DateParser.parse(row['delivered_on'], @logger, @line_number)
    end

    def world_locations
      Finders::WorldLocationsFinder.find(row['country_1'], row['country_2'], row['country_3'], row['country_4'], @logger, @line_number)
    end

  protected
    def attribute_keys
      super + [
        :delivered_on,
        :first_published_at,
        :location,
        :role_appointment,
        :speech_type,
        :lead_organisations,
        :related_editions,
        :topics,
        :world_locations
      ]
    end
  end
end
