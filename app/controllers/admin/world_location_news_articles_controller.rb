class Admin::WorldLocationNewsArticlesController < Admin::EditionsController
  before_filter :build_image, only: [:new, :edit]

private

  def edition_class
    WorldLocationNewsArticle
  end
end
