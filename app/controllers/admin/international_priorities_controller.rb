class Admin::InternationalPrioritiesController < Admin::DocumentsController
  before_filter :build_image, only: [:new, :edit]

  private

  def document_class
    InternationalPriority
  end
end
