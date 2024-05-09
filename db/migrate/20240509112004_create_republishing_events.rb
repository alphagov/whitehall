class CreateRepublishingEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :republishing_events do |t|
      t.text :action
      t.text :reason
      t.references :user, index: true

      t.timestamps
    end
  end
end
