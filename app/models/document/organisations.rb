module Document::Organisations
  extend ActiveSupport::Concern

  included do
    has_many :document_organisations, foreign_key: :document_id
    has_many :organisations, through: :document_organisations
  end
  
  module ClassMethods
    def in_organisation(organisation)
      joins(:organisations).where('organisations.id' => organisation)
    end
  end
end