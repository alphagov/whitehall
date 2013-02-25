class AddPolymorphicColumnsToCorporateInformationPages < ActiveRecord::Migration
  def change
    add_column :corporate_information_pages, :organisation_type, :string

    execute "UPDATE corporate_information_pages SET organisation_type = 'Organisation'"
    add_index  :corporate_information_pages, [:organisation_id, :organisation_type, :type_id], unique: true, name: 'index_corporate_information_pages_on_polymorphic_columns'
    remove_index :corporate_information_pages, column: [:organisation_id, :type_id]
  end
end
