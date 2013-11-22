class CreateTopicSuggestions < ActiveRecord::Migration
  def change
    create_table :topic_suggestions do |t|
      t.string :name
      t.belongs_to :edition

      t.timestamps
    end

    add_index :topic_suggestions, :edition_id
  end
end
