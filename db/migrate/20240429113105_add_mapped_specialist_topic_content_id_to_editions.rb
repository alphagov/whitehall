class AddMappedSpecialistTopicContentIdToEditions < ActiveRecord::Migration[7.1]
  def change
    add_column :editions, :mapped_specialist_topic_content_id, :string, null: true, default: nil
  end
end
