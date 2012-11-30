class AddSlugToOperationalFields < ActiveRecord::Migration
  OperationalField.class_eval do
    # temporarily generate slugs for existing objects
    def should_generate_new_friendly_id?
      true
    end
  end

  def change
    add_column :operational_fields, :slug, :string
    add_index :operational_fields, :slug

    OperationalField.reset_column_information

    OperationalField.record_timestamps = false
    OperationalField.all.each(&:save)
    OperationalField.record_timestamps = true
  end
end
