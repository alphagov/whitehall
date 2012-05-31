class AddSlugToPeople < ActiveRecord::Migration
  def change
    add_column :people, :slug, :string
    add_index :people, :slug, unique: true
    Person.observers.disable :all do
      Person.all.each do |p|
        # Resaving each person generates a slug
        p.save
      end
    end
  end
end
