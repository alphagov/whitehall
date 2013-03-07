class CreateEditionWorldwidePriorities < ActiveRecord::Migration
  def change
    create_table :edition_worldwide_priorities, force: true do |t|
      t.references :edition
      t.references :worldwide_priority
    end
  end
end
