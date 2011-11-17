class AddFeaturedToDocumentTopicRelationship < ActiveRecord::Migration
  def change
    add_column :document_topics, :featured, :boolean, default: false
  end
end