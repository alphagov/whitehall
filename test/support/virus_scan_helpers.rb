module VirusScanHelpers
  def self.simulate_virus_scan(*uploaders)
    if uploaders.empty?
      uploaders = AttachmentData.all.map(&:file) + ImageData.all.map(&:file)
    end

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

  def self.simulate_virus_scan_infected(*uploaders)
    if uploaders.empty?
      uploaders = AttachmentData.all.map(&:file) + ImageData.all.map(&:file)
    end

    uploaders.each do |uploader|
      absolute_path = File.join(Whitehall.incoming_uploads_root, uploader.relative_path)
      target_dir = File.join(Whitehall.infected_uploads_root, File.dirname(uploader.relative_path))
      if File.exists?(absolute_path)
        FileUtils.mkdir_p(target_dir)
        FileUtils.cp(absolute_path, target_dir)
        FileUtils.rm(absolute_path)
      end
    end
  end

  def self.erase_test_files
    raise "Only use VirusScanHelpers.erase_test_files in test mode" unless Rails.env.test?
    folders = [
      Whitehall.incoming_uploads_root,
      Whitehall.clean_uploads_root,
      Whitehall.infected_uploads_root
    ]

    folders.each do |folder|
      next unless Dir.exists?(folder)
      Dir.glob("#{folder}/*").each do |path|
        FileUtils.rm_rf(path)
      end
    end
  end
end