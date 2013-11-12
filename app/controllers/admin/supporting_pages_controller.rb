class Admin::SupportingPagesController < Admin::EditionsController

  before_filter :build_image, only: [:new, :edit]

private

  def edition_class
    SupportingPage
  end

end
