class RemoveMappedSpecialistTopicContentIdFromEditions < ActiveRecord::Migration[7.1]
  def change
    remove_column :editions, :mapped_specialist_topic_content_id, :string
  end
end
