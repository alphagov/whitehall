class RemoveAssociatedPolicyAreasFromNewsArticles < ActiveRecord::Migration
  def up
    execute %{
      DELETE document_policy_areas FROM document_policy_areas 
      INNER JOIN documents ON (documents.id = document_policy_areas.document_id)
      WHERE documents.type = 'NewsArticle'
    }
  end

  def down
  end
end
