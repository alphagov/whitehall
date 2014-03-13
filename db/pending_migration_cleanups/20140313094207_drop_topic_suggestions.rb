class DropTopicSuggestions < ActiveRecord::Migration
  def change
    drop_table :topic_suggestions
  end
end
