class DropCorporateInformationPagesTables < ActiveRecord::Migration
  def change
    drop_table :corporate_information_page_translations
    drop_table :corporate_information_pages
  end
end
