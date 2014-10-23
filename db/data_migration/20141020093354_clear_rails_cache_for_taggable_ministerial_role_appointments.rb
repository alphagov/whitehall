class TaggableContentCacheCleaner
  include Admin::TaggableContentHelper

  def do
    Rails.cache.delete(taggable_ministerial_role_appointments_cache_digest)
  end
end

TaggableContentCacheCleaner.new.do
