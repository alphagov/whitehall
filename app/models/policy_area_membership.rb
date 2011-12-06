class PolicyAreaMembership < ActiveRecord::Base
  belongs_to :policy, foreign_key: :document_id
  belongs_to :policy_area

  validates :policy, :policy_area, presence: true

  default_scope order("policy_area_memberships.ordering ASC")

  class << self
    def published
      joins(:policy).where("documents.state" => "published")
    end

    def for_type(type)
      joins(:policy).where("documents.type" => type)
    end
  end
end