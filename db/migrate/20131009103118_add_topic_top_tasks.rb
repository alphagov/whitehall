class AddTopicTopTasks < ActiveRecord::Migration
  def up
    create_table :topic_top_tasks do |t|
      t.integer :topic_id
      t.integer :top_task_id
    end
    add_index :topic_top_tasks, :topic_id
  end

  def down
    drop_table :topic_top_tasks
  end
end
