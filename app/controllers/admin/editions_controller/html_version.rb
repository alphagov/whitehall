module Admin::EditionsController::HtmlVersion
  extend ActiveSupport::Concern

  included do
    before_filter :build_html_version, only: [:new, :edit]
  end

  def build_html_version
    @edition.build_html_version unless @edition.html_version.present?
  end
end
