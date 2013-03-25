class FeatureList < ActiveRecord::Base
  has_many :features, dependent: :destroy, order: :ordering, before_add: :ensure_ordering!
  belongs_to :featurable, polymorphic: true

  validates_presence_of :locale
  validates_uniqueness_of :locale, scope: [:featurable_id, :featurable_type]

  accepts_nested_attributes_for :features

  def to_s
    "#{featurable.name} (#{locale})"
  end

  def featurable_editions
    featurable.published_editions.with_translations(locale)
  end

  def reorder!(new_ordering)
    Feature.connection.transaction do
      start_at = next_ordering
      new_ordering.each.with_index do |feature_id, i|
        feature = self.features.find_by_id(feature_id) || next
        feature.ordering = next_ordering + i
        feature.save
      end
    end
  end

  def published_features
    features.current.with_published_edition
  end

private
  def next_ordering
    (features.map(&:ordering).max || 0) + 1
  end

  def ensure_ordering!(new_feature)
    new_feature.ordering = next_ordering unless new_feature.ordering
  end
end
