Whitehall::Uploader::AttachmentCache.default_root_directory = if Rails.env.production?
  "/mnt/apps/whitehall-admin/attachment-cache"
else
  Rails.root.join("tmp", "cache", "attachment-cache")
end
