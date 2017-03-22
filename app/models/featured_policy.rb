class FeaturedPolicy < ActiveRecord::Base
  extend ActiveSupport::Concern

  belongs_to :organisation, inverse_of: :featured_policies, touch: true

  before_create :set_ordering, if: -> { ordering.blank? }

  def set_ordering
    self.ordering = next_ordering
  end

  def next_ordering
    max = organisation.featured_policies.maximum(:ordering)
    max ? max + 1 : 0
  end

  def title
    policy.title
  end

  def link
    policy.base_path
  end

  def policy
    @policy ||= Policy.find(policy_content_id)
  end
end
