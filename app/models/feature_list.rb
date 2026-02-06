class FeatureList < ApplicationRecord
  has_many :features, -> { order(:ordering) }, dependent: :destroy, before_add: :ensure_ordering!
  belongs_to :featurable, polymorphic: true

  validates :locale, presence: true
  validates :locale, uniqueness: { scope: %i[featurable_id featurable_type], case_sensitive: false }

  accepts_nested_attributes_for :features

  def to_s
    # This supports editionable and non-editionable parents
    display_name = featurable.respond_to?(:title) ? featurable.title : featurable.name
    "#{display_name} (#{locale})"
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
    republish_featurable_to_publishing_api
    true
  rescue ActiveRecord::RecordNotFound => e
    errors.add(:base, message: "Can't reorder because '#{e}'")
    false
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, message: "Can't reorder because '#{e}' on '#{e.record}'")
    false
  end

  def current
    # Legacy
    features.current.includes([:topical_event, { document: :live_edition }])
  end

  def published_features
    features.current.with_published_edition
  end

  def topical_events
    # Legacy
    features.current.with_topical_events
  end

  delegate :empty?, to: :current

  def republish_featurable_to_publishing_api
    if featurable.persisted?
      if featurable.is_a?(Organisation) || featurable.is_a?(WorldLocationNews)
        Whitehall::PublishingApi.republish_async(featurable)
      else
        Whitehall::PublishingApi.republish_document_async(featurable.document)
      end
    end
  end

  def deep_clone
    dup.tap do |new_list|
      new_list.features = features.map do |old_feature|
        new_feature = old_feature.dup
        clone_image_and_assets(old_feature, new_feature)
        new_feature
      end
    end
  end

private

  def clone_image_and_assets(old_feature, new_feature)
    old_image = old_feature.image
    return unless old_image

    new_image = new_feature.build_image(old_image.attributes.except("id", "featured_imageable_id"))
    old_image.assets.each do |old_asset|
      new_image.assets.build(old_asset.attributes.except("id", "assetable_id"))
    end
  end

  def next_ordering
    (features.map(&:ordering).max || 0) + 1
  end

  def ensure_ordering!(new_feature)
    new_feature.ordering = next_ordering unless new_feature.ordering
  end
end
