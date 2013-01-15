module Admin::EditionsController::NationalApplicability
  extend ActiveSupport::Concern

  included do
    before_filter :build_nation_inapplicabilities, only: [:new, :edit]
  end

  def build_edition_dependencies
    super
    process_nation_inapplicabilities
  end

  def process_nation_inapplicabilities
    set_nation_inapplicabilities_destroy_checkbox_state
    build_nation_inapplicabilities
  end

  def set_nation_inapplicabilities_destroy_checkbox_state
    @edition.nation_inapplicabilities.each { |ni| ni[:_destroy] = ni._destroy ? "1" : "0" }
  end

  def build_nation_inapplicabilities
    @edition.build_nation_applicabilities_for_all_nations
  end
end
