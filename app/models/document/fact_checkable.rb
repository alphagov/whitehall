module Document::FactCheckable
  extend ActiveSupport::Concern

  included do
    has_many :fact_check_requests, foreign_key: :document_id, dependent: :destroy
  end

  def can_be_fact_checked?
    true
  end
end