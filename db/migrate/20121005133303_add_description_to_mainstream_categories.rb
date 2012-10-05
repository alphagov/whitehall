class AddDescriptionToMainstreamCategories < ActiveRecord::Migration
  class MainstreamCategory < ActiveRecord::Base; end

  def up
    add_column :mainstream_categories, :description, :text

    data.each do |row|
      category = MainstreamCategory.find_by_title(row['name'])
      next unless category
      category.description = row['description']
      category.save
    end
  end

  def down
    remove_column :mainstream_categories, :description
  end

  def data
    CSV.read(
      File.dirname(__FILE__) + '/20121005133303_add_description_to_mainstream_categories.csv',
      headers: true)
  end
end
