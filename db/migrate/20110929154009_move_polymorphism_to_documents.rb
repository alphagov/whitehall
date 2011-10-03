class MovePolymorphismToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :type, :string, null: false, default: 'Policy'
    remove_column :editions, :document_type
  end
end
