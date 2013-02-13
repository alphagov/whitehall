class AddTranslatableTitleToWorldLocations < ActiveRecord::Migration
  def change
    add_column WorldLocation.translations_table_name, :title, :string

    execute(%{
      UPDATE #{WorldLocation.translations_table_name} t
      SET t.title = CONCAT('UK in ', t.name)
    })
  end
end
