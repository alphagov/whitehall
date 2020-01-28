class Admin::DocumentCollectionsController < Admin::EditionsController
  def edition_class
    DocumentCollection
  end
end
