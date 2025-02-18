class ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper
  def initialize(content_block_versions:, schema:)
    @content_block_versions = content_block_versions
    @schema = schema
  end

private

  attr_reader :content_block_versions, :schema

  def versions
    content_block_versions.reject { |version| hide_from_user?(version) }
  end

  def hide_from_user?(version)
    version.state.nil? || version.state == "superseded"
  end

  def first_published_version
    @first_published_version ||= content_block_versions.filter { |v| v.state == "published" }.min_by(&:created_at)
  end
end
