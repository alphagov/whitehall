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
        .multiple("topic_#", 0..4)
    end

    def news_article_type
      Finders::NewsArticleTypeFinder.find(row['news_article_type'], @logger, @line_number)
    end

    def related_editions
      Finders::EditionFinder.new(Policy, @logger, @line_number).find(row['policy_1'], row['policy_2'], row['policy_3'], row['policy_4'])
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

  protected
    def attribute_keys
      super + [
        :attachments,
        :first_published_at,
        :lead_organisations,
        :news_article_type,
        :related_editions,
        :role_appointments,
        :topics,
        :world_locations
      ]
    end
  end
end
