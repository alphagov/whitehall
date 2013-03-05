require 'whitehall/uploader/finders'
require 'whitehall/uploader/parsers'
require 'whitehall/uploader/builders'
require 'whitehall/uploader/row'

module Whitehall::Uploader
  class DetailedGuideRow < Row
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
        .multiple("topic_#", 1..4)
        .multiple("document_series_#", 1..4)
        .multiple("detailed_guidance_category_#", 1..4)
        .multiple("related_detailed_guide_#", 1..4)
        .multiple(%w{related_mainstream_content_url_# related_mainstream_content_title_#}, 1..2)
        .optional("first_published")
        .ignored("ignore_*")
        .multiple(%w{attachment_#_url attachment_#_title}, 0..Row::ATTACHMENT_LIMIT)
        .optional('json_attachments')
    end

    def legacy_urls
      Parsers::OldUrlParser.parse(row['old_url'], @logger, @line_number)
    end

    def title
      row['title']
    end

    def summary
      summary_text = row['summary']
      if summary_text.blank?
        Parsers::SummariseBody.parse(body)
      else
        summary_text
      end
    end

    def body
      row['body']
    end

    def organisations
      Finders::OrganisationFinder.find(row['organisation'], @logger, @line_number, @default_organisation)
    end

    def lead_organisations
      organisations
    end

    def topics
      Finders::SluggedModelFinder.new(Topic, @logger).find(fields(1..4, 'topic_#'))
    end

    def primary_mainstream_category
      Finders::SluggedModelFinder.new(MainstreamCategory, @logger).find([row['detailed_guidance_category_1']]).first
    end

    def other_mainstream_categories
      Finders::SluggedModelFinder.new(MainstreamCategory, @logger).find(fields(2..4, 'detailed_guidance_category_#'))
    end

    def document_series
      Finders::SluggedModelFinder.new(DocumentSeries, @logger).find(fields(1..4, 'document_series_#'))
    end

    def outbound_related_documents
      Finders::SluggedModelFinder.new(Document, @logger).find(fields(1..4, 'related_detailed_guide_#'))
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

    def attributes
      [
        :title, :summary, :body,
        :lead_organisations,
        :topics,
        :primary_mainstream_category,
        :other_mainstream_categories,
        :document_series,
        :outbound_related_documents,
        :related_mainstream_content_url,
        :related_mainstream_content_title,
        :additional_related_mainstream_content_url,
        :additional_related_mainstream_content_title,
        :attachments, :alternative_format_provider,
        :first_published_at].map.with_object({}) do |name, result|
        result[name] = __send__(name)
      end
    end

    private

    def fields(range, pattern)
      range.map do |n|
        row[pattern.gsub('#', n.to_s)]
      end
    end

    def attachments_from_json
      if row["json_attachments"]
        attachment_data = ActiveSupport::JSON.decode(row["json_attachments"])
        attachment_data.map do |attachment|
          Builders::AttachmentBuilder.build({title: attachment["title"]}, attachment["link"], @attachment_cache, @logger, @line_number)
        end
      else
        []
      end
    end

    def attachments_from_columns
      1.upto(Row::ATTACHMENT_LIMIT).map do |number|
        next unless row["attachment_#{number}_title"] || row["attachment_#{number}_url"]
        Builders::AttachmentBuilder.build({title: row["attachment_#{number}_title"]}, row["attachment_#{number}_url"], @attachment_cache, @logger, @line_number)
      end.compact
    end
  end
end
