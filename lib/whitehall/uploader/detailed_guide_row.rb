module Whitehall::Uploader
  class DetailedGuideRow < Row
    def self.validator
      super
        .multiple("topic_#", 1..4)
        .multiple("document_collection_#", 1..4)
        .multiple("detailed_guidance_category_#", 1..4)
        .multiple("related_detailed_guide_#", 1..4)
        .multiple(%w{related_mainstream_content_url_# related_mainstream_content_title_#}, 1..2)
        .optional("first_published")
        .ignored("ignore_*")
        .multiple(%w{attachment_#_url attachment_#_title}, 0..Row::ATTACHMENT_LIMIT)
        .optional('json_attachments')
    end

    def primary_mainstream_category
      Finders::SluggedModelFinder.new(MainstreamCategory, @logger, @line_number).find([row['detailed_guidance_category_1']]).first
    end

    def other_mainstream_categories
      Finders::SluggedModelFinder.new(MainstreamCategory, @logger, @line_number).find(fields(2..4, 'detailed_guidance_category_#'))
    end

    def document_collections
      fields(1..4, 'document_collection_#').compact.reject(&:blank?)
    end

    def outbound_related_documents
      Finders::SluggedModelFinder.new(Document, @logger, @line_number).find(fields(1..4, 'related_detailed_guide_#'))
    end

    def attachments
      attachments_from_columns + attachments_from_json
    end

    def alternative_format_provider
      organisations.first
    end

    def related_mainstream_content_url
      row['related_mainstream_content_url_1']
    end

    def related_mainstream_content_title
      row['related_mainstream_content_title_1']
    end

    def additional_related_mainstream_content_url
      row['related_mainstream_content_url_2']
    end

    def additional_related_mainstream_content_title
      row['related_mainstream_content_title_2']
    end

    def first_published_at
      Parsers::DateParser.parse(row['first_published'], @logger, @line_number)
    end

  protected
    def attribute_keys
      super + [
        :additional_related_mainstream_content_title,
        :additional_related_mainstream_content_url,
        :alternative_format_provider,
        :attachments,
        :first_published_at,
        :lead_organisations,
        :other_mainstream_categories,
        :outbound_related_documents,
        :primary_mainstream_category,
        :related_mainstream_content_title,
        :related_mainstream_content_url,
        :topics
      ]
    end
  end
end
