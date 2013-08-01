module Whitehall::Uploader
  class NewsArticleRow < Row
    def self.validator
      super
        .ignored("ignore_*")
        .required(%w{news_article_type first_published})
        .multiple("policy_#", 0..4)
        .multiple("minister_#", 0..2)
        .multiple("country_#", 0..4)
        .multiple(%w{attachment_#_url attachment_#_title}, 0..Row::ATTACHMENT_LIMIT)
        .optional('json_attachments')
        .translatable(%w{title summary body})
    end

    def news_article_type
      Finders::NewsArticleTypeFinder.find(row['news_article_type'], @logger, @line_number)
    end

    def first_published_at
      Parsers::DateParser.parse(row['first_published'], @logger, @line_number)
    end

    def related_editions
      Finders::PoliciesFinder.find(row['policy_1'], row['policy_2'], row['policy_3'], row['policy_4'], @logger, @line_number)
    end

    def role_appointments
      Finders::RoleAppointmentsFinder.find(first_published_at, row['minister_1'], row['minister_2'], @logger, @line_number)
    end

    def world_locations
      Finders::WorldLocationsFinder.find(row['country_1'], row['country_2'], row['country_3'], row['country_4'], @logger, @line_number)
    end

    def attachments
      attachments_from_columns + attachments_from_json
    end

    def attributes
      [:title, :summary, :body, :lead_organisations,
       :first_published_at, :related_editions, :role_appointments,
       :world_locations, :news_article_type, :attachments].map.with_object({}) do |name, result|
        result[name] = __send__(name)
      end
    end
  end
end
