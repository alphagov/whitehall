class FeatureList < ActiveRecord::Base
  has_many :features, dependent: :destroy, order: :ordering, before_add: :ensure_ordering!
  belongs_to :featurable, polymorphic: true

  validates_presence_of :locale
  validates_uniqueness_of :locale, scope: [:featurable_id, :featurable_type]

  accepts_nested_attributes_for :features

  def to_s
    "#{featurable.name} (#{locale})"
  end

  def reorder!(new_ordering)
    Feature.connection.transaction do
      start_at = next_ordering
      new_ordering.each.with_index do |feature_id, i|
        feature = self.features.find_by_id!(feature_id)
        feature.ordering = start_at + i
        feature.save!
      end
    end
    true
  rescue ActiveRecord::RecordNotFound => e
    self.errors[:base] << "Can't reorder because '#{e}'"
    false
  rescue ActiveRecord::RecordInvalid => e
    self.errors[:base] << "Can't reorder because '#{e}' on '#{e.record}'"
    false
  end

  def current
    features.current.includes([:topical_event, { document: :published_edition }])
  end

  def published_features
    features.current.with_published_edition
  end

  def topical_events
    features.current.with_topical_events
  end

  def empty?
    current.empty?
  end

private
  def next_ordering
    (features.map(&:ordering).max || 0) + 1
  end

  def ensure_ordering!(new_feature)
    new_feature.ordering = next_ordering unless new_feature.ordering
  end
end
