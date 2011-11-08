class AddOrderingToDocumentTopicAssociation < ActiveRecord::Migration
  def change
    add_column :document_topics, :id, :primary_key
    add_column :document_topics, :ordering, :integer
  end
end