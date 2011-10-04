class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics, force: true do |t|
      t.string :name
      t.timestamps
    end
    create_table :document_topics, force: true, id: false do |t|
      t.references :document
      t.references :topic
      t.timestamps
    end
  end
end
