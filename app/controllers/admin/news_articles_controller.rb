class Admin::NewsArticlesController < Admin::EditionsController
  include Admin::EditionsController::Attachments
  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    NewsArticle
  end
end
