class AddNewArticleTypeIdToEditions < ActiveRecord::Migration
  def up
    add_column :editions, :news_article_type_id, :integer

    NewsArticle.reset_column_information

    NewsArticle.unscoped.update_all news_article_type_id: 999
  end

  def down
    remove_column :editions, :news_article_type_id
  end
end
