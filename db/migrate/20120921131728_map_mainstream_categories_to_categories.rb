class MapMainstreamCategoriesToCategories < ActiveRecord::Migration
  class MainstreamCategory < ActiveRecord::Base
  end

  def up
    add_column :mainstream_categories, :parent_tag, :string
    MainstreamCategory.reset_column_information
    load_seed_data!
  end

  def down
    remove_column :mainstream_categories, :parent_tag
  end

  private

  def load_seed_data!
    titles = {}
    titles["business/international-trade"] = [
      "Import and export procedures",
      "Import and export controls",
      "Embargoes and sanctions",
      "Transport of goods",
      "Transit systems and procedures",
      "Freight forwarding",
      "Tax, customs and duty",
      "Service industries trade compliance",
      "Manufactured goods trade compliance",
      "Food and agriculture trade compliance",
      "Natural resources and chemicals trade compliance"
    ]

    titles.each do |parent_path, children|
      children.each do |title|
        category = MainstreamCategory.where(title: title).first
        if category
          category.parent_tag = parent_path
          category.save
        end
      end
    end
  end
end
