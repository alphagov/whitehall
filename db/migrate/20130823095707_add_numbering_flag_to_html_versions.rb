class AddNumberingFlagToHtmlVersions < ActiveRecord::Migration
  def change
    add_column :html_versions, :manually_numbered, :boolean, default: false
  end
end
