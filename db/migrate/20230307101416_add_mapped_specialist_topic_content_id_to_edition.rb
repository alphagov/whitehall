class AddMappedSpecialistTopicContentIdToEdition < ActiveRecord::Migration[7.0]
  def change
    add_column :editions, :mapped_specialist_topic_content_id, :string
  end
end
