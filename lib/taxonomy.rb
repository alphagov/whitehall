require 'taxonomy/linked_edition'
require 'taxonomy/publishing_api_linked_edition_parser'

module Taxonomy
  EDUCATION_CONTENT_ID = "c58fdadd-7743-46d6-9629-90bb3ccc4ef0".freeze
  DRAFT_CONTENT_IDS = ["a544d48b-1e9e-47fb-b427-7a987c658c14", "206b7f3a-49b5-476f-af0f-fd27e2a68473"].freeze

  def self.drafts
    DRAFT_CONTENT_IDS.map do |content_id|
      content_item = Services.publishing_api.get_content(content_id)
      expanded_links = Services.publishing_api.get_expanded_links(content_id, with_drafts: true)

      parser = PublishingApiLinkedEditionParser.new(content_item)
      parser.add_expanded_links(expanded_links)
      parser.linked_edition
    end
  end

  def self.education
    content_item = Services.publishing_api.get_content(EDUCATION_CONTENT_ID)
    expanded_links = Services.publishing_api.get_expanded_links(EDUCATION_CONTENT_ID, with_drafts: false)

    parser = PublishingApiLinkedEditionParser.new(content_item)
    parser.add_expanded_links(expanded_links)
    parser.linked_edition
  end
end
