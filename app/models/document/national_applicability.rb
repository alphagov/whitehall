module Document::NationalApplicability
  extend ActiveSupport::Concern

  included do
    has_many :nation_inapplicabilities, foreign_key: :document_id
    has_many :inapplicable_nations, through: :nation_inapplicabilities, source: :nation
  end

end