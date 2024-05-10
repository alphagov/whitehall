class CreateRepublishingEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :republishing_events do |t|
      t.text :action, null: false
      t.text :reason, null: false
      t.references :user, index: true, null: false

      t.timestamps
    end
  end
end
