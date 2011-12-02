class DocumentPolicyArea < ActiveRecord::Base
  belongs_to :document
  belongs_to :policy_area

  validates :document, :policy_area, presence: true

  default_scope order("document_policy_areas.ordering ASC")

  class << self
    def published
      joins(:document).where("documents.state" => "published")
    end

    def for_type(type)
      joins(:document).where("documents.type" => type)
    end
  end
end