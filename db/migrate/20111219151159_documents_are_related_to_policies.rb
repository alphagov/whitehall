class DocumentsAreRelatedToPolicies < ActiveRecord::Migration

  class DocumentRelationTable < ActiveRecord::Base
    self.table_name = "document_relations"
  end

  def up
    rename_column :document_relations, :related_document_id, :policy_id

    relations = ActiveRecord::Base.connection.select_all(%{
      SELECT dr.id, d.id AS document_id, d.type AS document_type,
                    d2.id AS policy_id, d2.type AS policy_type
      FROM document_relations dr
      INNER JOIN documents d ON d.id = dr.document_id
      INNER JOIN documents d2 ON d2.id = dr.policy_id
    })
    valid, invalid = relations.partition { |x| x["policy_type"] == "Policy" }
    invalid.each do |relation|
      corresponding_valids = valid.select do |x|
        x["document_id"] == relation["policy_id"] &&
        x["policy_id"] == relation["document_id"]
      end
      unless corresponding_valids.length == 1
        raise "Should only be one corresponding valid relation! #{corresponding_valids.inspect}"
      end
    end
    # If we got to here, then the data is consistent and we can simply drop the invalid data
    DocumentRelationTable.destroy(invalid.map { |x| x["id"] })
  end

  def down
    relations = ActiveRecord::Base.connection.select_all(%{
      SELECT * from document_relations
    })

    relations.each do |relation|
      ActiveRecord::Base.connection.insert(%{
        INSERT INTO document_relations (document_id, policy_id, created_at, updated_at)
        VALUES (#{relation["policy_id"]}, #{relation["document_id"]},
                "#{relation["created_at"].to_s(:db)}", "#{relation["updated_at"].to_s(:db)}")
      })
    end

    rename_column :document_relations, :policy_id, :related_document_id
  end
end