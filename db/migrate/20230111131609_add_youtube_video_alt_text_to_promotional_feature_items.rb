class AddYoutubeVideoAltTextToPromotionalFeatureItems < ActiveRecord::Migration[7.0]
  def change
    add_column :promotional_feature_items, :youtube_video_alt_text, :string
  end
end
