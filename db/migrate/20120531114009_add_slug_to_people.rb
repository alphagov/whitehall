class AddSlugToPeople < ActiveRecord::Migration
  class Person < ActiveRecord::Base
  end

  def change
    add_column :people, :slug, :string
    add_index :people, :slug, unique: true
    Person.observers.disable :all do
      Person.all.each do |p|
        class << p
          def privy_counsellor?
            false
          end
        end
        # Resaving each person generates a slug
        p.save
      end
    end
  end
end
