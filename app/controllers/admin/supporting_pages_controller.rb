class Admin::SupportingPagesController < Admin::EditionsController

  before_filter :build_image, only: [:new, :edit]

private

  def edition_class
    SupportingPage
  end

  def document_can_be_previously_published
    false
  end

end
