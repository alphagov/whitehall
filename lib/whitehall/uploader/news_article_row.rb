require 'whitehall/uploader/finders'
require 'whitehall/uploader/parsers'
require 'whitehall/uploader/builders'
require 'whitehall/uploader/row'

module Whitehall::Uploader
  class NewsArticleRow < Row
    attr_reader :row

    def initialize(row, line_number, attachment_cache = nil, logger = Logger.new($stdout))
      @row = row
      @line_number = line_number
      @logger = logger
    end

    def self.required_fields(headings)
      super +
        %w{policy_1 policy_2 policy_3 policy_4} +
        %w{first_published country_1 country_2 country_3 minister_1 minister_2}
    end

    def legacy_url
      row['old_url']
    end

    def title
      row['title']
    end

    def summary
      Parsers::RelativeToAbsoluteLinks.parse(row['summary'], organisation.url)
    end

    def body
      Parsers::RelativeToAbsoluteLinks.parse(row['body'], organisation.url)
    end

    def organisation
      @organisation ||= Finders::OrganisationFinder.find(row['organisation'], @logger, @line_number).first
    end

    def organisations
      [organisation]
    end

    def first_published_at
      Parsers::DateParser.parse(row['first_published'], @logger, @line_number)
    end

    def related_policies
      Finders::PoliciesFinder.find(row['policy_1'], row['policy_2'], row['policy_3'], row['policy_4'], @logger, @line_number)
    end

    def role_appointments
      Finders::RoleAppointmentsFinder.find(first_published_at, row['minister_1'], row['minister_2'], @logger, @line_number)
    end

    def attributes
      [:title, :summary, :body, :organisations, :first_published_at, :related_policies, :role_appointments].map.with_object({}) do |name, result|
        result[name] = __send__(name)
      end
    end
  end
end
