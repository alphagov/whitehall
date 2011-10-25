module Document::NationalApplicability
  extend ActiveSupport::Concern

  included do
    has_many :nation_applicabilities, foreign_key: :document_id
    has_many :nations, through: :nation_applicabilities

    before_save :ensure_applicable_to_england
  end

  def inapplicable_nations
    Nation.all - nations
  end

  private

  def ensure_applicable_to_england
    nations << Nation.england unless nations.include?(Nation.england)
  end
end