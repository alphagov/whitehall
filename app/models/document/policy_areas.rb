module Document::PolicyAreas
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_before_save(document)
      document.policy_area_memberships = @document.policy_area_memberships.map do |dt|
        PolicyAreaMembership.new(dt.attributes.except(:id))
      end
    end
  end

  included do
    has_many :policy_area_memberships
    has_many :policy_areas, through: :policy_area_memberships

    add_trait Trait
  end

  def can_be_associated_with_policy_areas?
    true
  end

  module ClassMethods
    def in_policy_area(policy_area)
      joins(:policy_areas).where('policy_areas.id' => policy_area)
    end
  end
end