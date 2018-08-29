# DID YOU MEAN: Policy Area?
# "Policy area" is the newer name for "topic"
# (https://www.gov.uk/government/topics)
# "Topic" is the newer name for "specialist sector"
# (https://www.gov.uk/topic)
# You can help improve this code by renaming all usages of this field to use
# the new terminology.
class Topic < Classification
  include PublishesToPublishingApi

  has_many :featured_links, -> { order(:created_at) }, as: :linkable, dependent: :destroy
  accepts_nested_attributes_for :featured_links, reject_if: ->(attributes) { attributes['url'].blank? }, allow_destroy: true
  has_many :statistics_announcement_topics, inverse_of: :topic

  def self.with_statistics_announcements
    joins(:statistics_announcement_topics)
      .group('statistics_announcement_topics.topic_id')
  end

  def unpublish_and_redirect(redirect_path)
    Services.publishing_api.unpublish(
      self.content_id,
      alternative_path: redirect_path,
      type: "redirect",
      discard_drafts: true
    )
    self.delete
  end
end
