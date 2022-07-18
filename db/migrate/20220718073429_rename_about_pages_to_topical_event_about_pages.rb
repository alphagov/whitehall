class RenameAboutPagesToTopicalEventAboutPages < ActiveRecord::Migration[7.0]
  def change
    rename_table :about_pages, :topical_event_about_pages
  end
end
