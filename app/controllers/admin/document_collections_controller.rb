class Admin::DocumentCollectionsController < Admin::EditionsController
  before_action :build_blank_brexit_no_deal_content_notice_links, only: %i[new edit]

  private

  def edition_class
    DocumentCollection
  end
end
