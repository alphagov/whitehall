class AddSlugsToCountries < ActiveRecord::Migration
  Country.class_eval do
    # temporarily generate slugs for existing objects
    def should_generate_new_friendly_id?
      super
    end
  end

  def change
    add_column :countries, :slug, :string
    add_index :countries, :slug

    Country.reset_column_information

    Country.record_timestamps = false
    Country.all.each(&:save)
    Country.record_timestamps = true
  end
end
