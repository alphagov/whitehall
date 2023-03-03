class SpecialistTopicFetcher
  def initialize(base_path)
    @base_path = base_path
  end

  def self.call(*args)
    new(*args).permitted_specialist_topic
  end

  def permitted_specialist_topic
    validate!
    specialist_topic_content_item
  end

private

  attr_reader :base_path

  def validate!
    @errors = []
    @errors << "Not a level two topic" unless level_two_specialist_topic?
    @errors << "Not a curated topic" unless curated_specialist_topic?

    if @errors.any?
      raise @errors.first
    end
  end

  def level_two_specialist_topic?
    specialist_topic_links.dig(:links, :parent).present?
  end

  def specialist_topic_links
    Services.publishing_api.get_links(specialist_topic_content_id).to_h.deep_symbolize_keys
  end

  def specialist_topic_content_id
    content_id = Services.publishing_api.lookup_content_id(base_path:)

    raise "No specialist topic with that base path" unless content_id

    content_id
  end

  def curated_specialist_topic?
    specialist_topic_groups.present?
  end

  def specialist_topic_groups
    specialist_topic_content_item.dig(:details, :groups)
  end

  def specialist_topic_content_item
    Services.publishing_api.get_content(specialist_topic_content_id).to_h.deep_symbolize_keys
  end
end
