class AddIndexOnPublicTimestampAndDocumentId < ActiveRecord::Migration
  def change
    add_index :editions, [:public_timestamp, :document_id]
  end
end
