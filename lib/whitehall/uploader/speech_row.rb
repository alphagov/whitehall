require 'whitehall/uploader/row'

module Whitehall::Uploader
  class SpeechRow < Row
    attr_reader :row

    def initialize(row, line_number, attachment_cache, default_organisation, logger = Logger.new($stdout))
      @row = row
      @line_number = line_number
      @logger = logger
      @attachment_cache = attachment_cache
      @default_organisation = default_organisation
    end

    def self.validator
      HeadingValidator.new
        .required(%w{old_url title summary body organisation})
        .ignored("ignore_*")
        .required("type")
        .multiple("policy_#", 1..4)
        .required(%w{delivered_by delivered_on event_and_location})
        .multiple("country_#", 0..4)
    end

    def legacy_url
      row['old_url']
    end

    def title
      row['title']
    end

    def body
      row['body']
    end

    def summary
      row['summary']
    end

    def organisations
      Finders::OrganisationFinder.find(row['organisation'], @logger, @line_number, @default_organisation)
    end

    def speech_type
      Finders::SpeechTypeFinder.find(row['type'], @logger, @line_number)
    end

    def role_appointment
      Finders::RoleAppointmentsFinder.find(delivered_on, row['delivered_by'], @logger, @line_number).first
    end

    def related_policies
      Finders::PoliciesFinder.find(row['policy_1'], row['policy_2'], row['policy_3'], row["policy_4"], @logger, @line_number)
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

    def attributes
      [:title, :summary, :body, :speech_type,
       :role_appointment, :delivered_on, :location, :organisations,
       :related_policies, :first_published_at,
       :world_locations].map.with_object({}) do |name, result|
        result[name] = __send__(name)
      end
    end

    def world_locations
      Finders::WorldLocationsFinder.find(row['country_1'], row['country_2'], row['country_3'], row['country_4'], @logger, @line_number)
    end

  end
end
