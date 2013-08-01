module VirusScanHelpers
  def self.simulate_virus_scan(*uploaders)
    uploaders = AttachmentData.all.map(&:file) if uploaders.empty?

    uploaders.each do |uploader|
      absolute_path = File.join(Whitehall.incoming_uploads_root, uploader.relative_path)
      target_dir = File.join(Whitehall.clean_uploads_root, File.dirname(uploader.relative_path))
      if File.exists?(absolute_path)
        FileUtils.mkdir_p(target_dir)
        FileUtils.cp(absolute_path, target_dir)
        FileUtils.rm(absolute_path)
      end
    end
  end
end