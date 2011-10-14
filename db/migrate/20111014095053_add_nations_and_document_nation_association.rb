class AddNationsAndDocumentNationAssociation < ActiveRecord::Migration
  def change
    create_table :nations, force: true do |t|
      t.string :name
    end

    create_table :nation_applicabilities, force: true do |t|
      t.references :nation
      t.references :document
      t.timestamps
    end
  end
end