class UseRelatedDocumentsForWorldwidePriorityLinks < ActiveRecord::Migration
  class EditionWorldwidePriority < ActiveRecord::Base
    belongs_to :edition
    belongs_to :worldwide_priority
  end

  def up
    EditionWorldwidePriority.find_each do |ewp|
      ewp.edition.related_documents << ewp.worldwide_priority.document
    end
    drop_table :edition_worldwide_priorities
  end

  def down
    create_table :edition_worldwide_priorities, force: true do |t|
      t.references :edition
      t.references :worldwide_priority
    end
  end
end
