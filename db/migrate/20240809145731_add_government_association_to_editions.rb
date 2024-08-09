class AddGovernmentAssociationToEditions < ActiveRecord::Migration[7.1]
  def change
    change_table :editions do |t|
      t.belongs_to :government, foreign_key: true, type: :integer
    end
  end
end
