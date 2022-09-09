class FeatureList < ApplicationRecord
  has_many :features, -> { order(:ordering) }, dependent: :destroy, before_add: :ensure_ordering!
  belongs_to :featurable, polymorphic: true

  validates :locale, presence: true
  validates :locale, uniqueness: { scope: %i[featurable_id featurable_type], case_sensitive: false }

  accepts_nested_attributes_for :features

  def to_s
    "#{featurable.name} (#{locale})"
  end

  def reorder!(new_ordering)
    Feature.connection.transaction do
      start_at = next_ordering
      new_ordering.each.with_index do |feature_id, i|
        feature = features.find(feature_id)
        feature.ordering = start_at + i
        feature.save!
      end
    end
    republish_organisation_to_publishing_api
    true
  rescue ActiveRecord::RecordNotFound => e
    errors.add(:base, message: "Can't reorder because '#{e}'")
    false
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, message: "Can't reorder because '#{e}' on '#{e.record}'")
    false
  end

  def current
    features.current.includes([:topical_event, { document: :live_edition }])
  end

  def published_features
    features.current.with_published_edition
  end

  def topical_events
    features.current.with_topical_events
  end

  delegate :empty?, to: :current

  def republish_organisation_to_publishing_api
    if featurable.is_a?(Organisation) && featurable.persisted?
      Whitehall::PublishingApi.republish_async(featurable)
    end
  end

private

  def next_ordering
    (features.map(&:ordering).max || 0) + 1
  end

  def ensure_ordering!(new_feature)
    new_feature.ordering = next_ordering unless new_feature.ordering
  end
end
