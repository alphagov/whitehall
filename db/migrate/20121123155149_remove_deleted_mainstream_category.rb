class RemoveDeletedMainstreamCategory < ActiveRecord::Migration
  class EditionMainstreamCategory < ActiveRecord::Base
    belongs_to :mainstream_category
  end
  class MainstreamCategory < ActiveRecord::Base
  end

  def up
    puts "Removing all edition associations with the tax-and-legislation-for-corporations category"
    category_to_delete = MainstreamCategory.where(slug: 'tax-and-legislation-for-corporations').first

    if category_to_delete
      EditionMainstreamCategory.where(mainstream_category_id: category_to_delete).destroy_all

      puts "Remove the tax-and-legislation-for-corporations mainstream sub-category"
      category_to_delete.destroy
    end
  end

  def down
    # No down migration as we are just removing a category
  end
end
