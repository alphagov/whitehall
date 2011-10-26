class Admin::ConsultationsController < Admin::DocumentsController

  before_filter :build_nation_inapplicabilities, only: [:new, :edit]

  private

  def document_class
    Consultation
  end

  def build_nation_inapplicabilities
    @document.applicable_nations.each { |nation| @document.nation_inapplicabilities.build(nation: nation) }
    @document.nation_inapplicabilities.sort_by! { |na| na.nation }
  end
end