FactoryBot.define do
  factory :promotional_feature_item do
    association :promotional_feature
    summary { "Summary text" }
    image { image_fixture_file }
    image_alt_text { "Image alt text" }

    trait(:with_youtube_video_url) do
      image { nil }
      image_alt_text { nil }
      youtube_video_url { "https://www.youtube.com/watch?v=fFmDQn9Lbl4" }
    end
  end
end
