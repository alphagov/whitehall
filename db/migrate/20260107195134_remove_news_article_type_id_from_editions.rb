class RemoveNewsArticleTypeIdFromEditions < ActiveRecord::Migration[8.0]
  def up
    safety_assured { remove_column :editions, :news_article_type_id, :integer }
  end

  def down
    add_column :editions, :news_article_type_id, :integer
  end
end
