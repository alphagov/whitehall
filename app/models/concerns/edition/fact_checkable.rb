module Edition::FactCheckable
  extend ActiveSupport::Concern

  included do
    has_many :fact_check_requests, foreign_key: :edition_id, dependent: :destroy
  end

  def all_completed_fact_check_requests
    FactCheckRequest.completed.for_editions(document.editions).order("updated_at DESC")
  end

  def can_be_fact_checked?
    true
  end
end
