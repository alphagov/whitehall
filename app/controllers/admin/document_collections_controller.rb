class Admin::DocumentCollectionsController < Admin::EditionsController
  private

  def edition_class
    DocumentCollection
  end
end
