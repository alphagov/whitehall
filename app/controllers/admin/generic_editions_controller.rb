class Admin::GenericEditionsController < Admin::EditionsController
private

  def edition_class
    GenericEdition
  end
end
