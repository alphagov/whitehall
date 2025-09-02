class WhitehallDownloader < CarrierWave::Downloader::Base
  def skip_ssrf_protection?(_uri)
    Rails.env.development? || Rails.env.test?
  end
end
