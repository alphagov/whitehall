class RemoveDeletedMainstreamCategory < ActiveRecord::Migration
  class EditionMainstreamCategory < ActiveRecord::Base
    belongs_to :mainstream_category
  end

  def up
    puts "Removing all edition associations with the tax-and-legislation-for-corporations category"
    EditionMainstreamCategory.where(mainstream_category_id: 46).destroy_all

    puts "Remove the tax-and-legislation-for-corporations mainstream sub-category"
    execute "DELETE FROM mainstream_categories WHERE id = 46"
  end

  def down
    # No down migration as we are just removing a category
  end
end
