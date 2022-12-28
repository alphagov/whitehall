class AddYoutubeVideoUrlToPromotionalFeatures < ActiveRecord::Migration[7.0]
  def change
    add_column :promotional_feature_items, :youtube_video_url, :string
  end
end
