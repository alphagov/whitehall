require 'whitehall/uploader/finders'
require 'whitehall/uploader/parsers'
require 'whitehall/uploader/builders'
module Whitehall::Uploader
  class NewsArticleRow
    attr_reader :row

    def initialize(row, line_number, attachment_cache = nil, logger = Logger.new($stdout))
      @row = row
      @line_number = line_number
      @logger = logger
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
