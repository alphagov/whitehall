class LengthenHtmlVersionBody < ActiveRecord::Migration
  def change
    change_column :html_versions, :body, :text, limit: 4.gigabytes - 1
  end
end
