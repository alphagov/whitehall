require 'whitehall/uploader/finders'
require 'whitehall/uploader/parsers'
require 'whitehall/uploader/builders'
require 'whitehall/uploader/row'

module Whitehall::Uploader
  class NewsArticleRow < Row
    attr_reader :row

    def initialize(row, line_number, attachment_cache, default_organisation, logger = Logger.new($stdout))
      @row = row
      @line_number = line_number
      @logger = logger
      @default_organisation = default_organisation
    end

    def self.validator
      HeadingValidator.new
        .required(%w{old_url title summary body organisation})
        .ignored("ignore_*")
        .required(%w{news_article_type first_published})
        .multiple("policy_#", 1..4)
        .multiple("minister_#", 1..2)
        .multiple("country_#", 0..4)
    end

    def legacy_urls
      Parsers::OldUrlParser.parse(row['old_url'], @logger, @line_number)
    end

    def title
      row['title']
    end

    def summary
      summary_text = Parsers::RelativeToAbsoluteLinks.parse(row['summary'], organisation.url)
      if summary_text.blank?
        Parsers::SummariseBody.parse(body)
      else
        summary_text
      end
    end

    def body
      Parsers::RelativeToAbsoluteLinks.parse(row['body'], organisation.url)
    end

    def news_article_type
      Finders::NewsArticleTypeFinder.find(row['news_article_type'], @logger, @line_number)
    end

    def organisation
      @organisation ||= Finders::OrganisationFinder.find(row['organisation'], @logger, @line_number, @default_organisation).first
    end

    def organisations
      [organisation]
    end

    def lead_organisations
      organisations
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

    def world_locations
      Finders::WorldLocationsFinder.find(row['country_1'], row['country_2'], row['country_3'], row['country_4'], @logger, @line_number)
    end

    def attributes
      [:title, :summary, :body, :lead_organisations,
       :first_published_at, :related_policies, :role_appointments,
       :world_locations, :news_article_type].map.with_object({}) do |name, result|
        result[name] = __send__(name)
      end
    end
  end
end
