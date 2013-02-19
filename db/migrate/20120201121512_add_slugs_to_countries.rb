class AddSlugsToCountries < ActiveRecord::Migration
  class Country < ActiveRecord::Base
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
