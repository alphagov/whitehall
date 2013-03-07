class UseRelatedDocumentsForWorldwidePriorityLinks < ActiveRecord::Migration
  def up
    # NOTE: this will remove all the links between editions and
    # worldwide priorities. As it's not in production yet and no links exist
    # this is acceptable.
    drop_table :edition_worldwide_priorities
  end

  def down
    create_table :edition_worldwide_priorities, force: true do |t|
      t.references :edition
      t.references :worldwide_priority
    end
  end
end
