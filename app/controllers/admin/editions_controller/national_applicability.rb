module Admin::EditionsController::NationalApplicability
  extend ActiveSupport::Concern

  included do
    before_filter :build_nation_inapplicabilities, only: [:new, :edit]
  end

  def build_edition_dependencies
    super
    build_nation_inapplicabilities
  end

  def build_nation_inapplicabilities
    @edition.build_nation_applicabilities_for_all_nations
  end
end
