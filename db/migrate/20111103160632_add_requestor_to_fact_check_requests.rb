class AddRequestorToFactCheckRequests < ActiveRecord::Migration
  def change
    add_column :fact_check_requests, :requestor_id, :integer
    update %{
      UPDATE fact_check_requests, documents
        SET fact_check_requests.requestor_id = documents.author_id
        WHERE fact_check_requests.document_id = documents.id
    }
  end
end
