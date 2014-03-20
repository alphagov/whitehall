class AddCorporateInformationPageTypeIdToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :corporate_information_page_type_id, :integer
  end
end
