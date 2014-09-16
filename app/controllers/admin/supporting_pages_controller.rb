class Admin::SupportingPagesController < Admin::EditionsController

private

  def edition_class
    SupportingPage
  end

  def document_can_be_previously_published
    false
  end

end
