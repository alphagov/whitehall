class CreateMainstreamCategories < ActiveRecord::Migration
  class MainstreamCategory < ActiveRecord::Base; end

  def up
    create_table :mainstream_categories do |t|
      t.string :slug
      t.string :identifier
      t.string :title
      t.string :parent_title
      t.timestamps
    end

    add_index :mainstream_categories, :identifier, unique: true
    add_index :mainstream_categories, :slug, unique: true

    add_column :editions, :mainstream_category_id, :integer
    load_seed_data!
  end

  def down
    remove_column :editions, :mainstream_category_id
    remove_index :mainstream_categories, :slug
    remove_index :mainstream_categories, :identifier
    drop_table :mainstream_categories
  end

  def load_seed_data!
    titles = {}
    titles["International trade"] = [
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
    titles["Food and farming"] = [
      "Farm business planning",
      "Managing farm employees",
      "Trading farm produce",
      "Farm health and safety",
      "Financial support for farming",
      "Managing farm waste",
      "Managing environmental resources on farms",
      "Land and conservation on farms",
      "Wildlife on farms",
      "Farm animal health and welfare",
      "Cattle farming",
      "Pig farming",
      "Poultry farming",
      "Sheep, goat and deer farming",
      "Crops, seeds and horticulture on farms",
      "Plant health on farms",
      "Organic farming"
    ]
    titles.each do |parent_title, children|
      children.each do |title|
        MainstreamCategory.create(
          title: title,
          identifier: "https://example.com/tags/#{title.parameterize}.json",
          parent_title: parent_title,
          slug: title.parameterize)
      end
    end
  end
end
