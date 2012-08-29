def log(message)
  puts message
end

def exit_with_usage_message
  puts "Usage: script/rails r #{__FILE__} /path/to/publications.csv /path/to/download/directory"
  exit 1
end

def create_attachments(download_directory)
  Dir[File.join(download_directory, "*")].each do |attachment_directory|
    log "Considering attachment #{attachment_directory}"
    files = Dir[File.join(attachment_directory, "*")]
    metadata_path = files.delete(File.join(attachment_directory, "metadata.json"))
    attachment_path = files.first
    if metadata_path && attachment_path
      metadata = ActiveSupport::JSON.decode(File.read(metadata_path))
      log "\tBuilding attachment for publication #{metadata["publication_id"]}"
      if EditionAttachment.where(edition_id: metadata["publication_id"]).exists?
        log "\tSkipping; attachment already exists"
      else
        command = %{RAILS_ENV=#{ENV["RAILS_ENV"]} bundle exec rails r upload_attachment.rb "#{attachment_path}" "#{metadata_path}"}
        output = `#{command}`
        if $?.success?
          log output
        else
          log "\tERROR: Couldn't save attachment:"
          log output
        end
      end
    else
      log "\tNo attachment data in #{attachment_directory}"
    end
  end
end

if __FILE__ == $0
  download_directory = ARGV.shift
  exit_with_usage_message unless download_directory
  create_attachments(download_directory)
end
