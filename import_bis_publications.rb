# encoding: UTF-8
require 'csv'
require 'fileutils'

def log(message)
  puts message
end

def exit_with_usage_message
  puts "Usage: script/rails r #{__FILE__} /path/to/publications.csv /path/to/download/directory"
  exit 1
end

csv_filename = ARGV.shift
exit_with_usage_message unless csv_filename && File.exists?(csv_filename)

download_directory = ARGV.shift
exit_with_usage_message unless download_directory

unless File.directory?(download_directory)
  log "Creating download directory: #{download_directory}"
  FileUtils.mkdir_p(download_directory)
end

unless bis = Organisation.find_by_acronym("BIS")
  puts "This script assumes that the 'BIS' organisation exists.  Please create it and re-run the script."
  exit 1
end

unless user = User.find_by_name("Automatic Data Importer")
  puts "This script assumes that the 'Automatic Data Importer' user exists.  Please create it and re-run the script."
  exit 1
end

def attachment_directory_for(url)
  Digest::SHA1.hexdigest(url)
end

def download_attachments(directory, urls)
  urls.each do |url|
    attachment_directory = "#{directory}/#{attachment_directory_for(url)}"
    FileUtils.mkdir_p(attachment_directory)
    if url =~ /createsend/
      log "Skipping invalid URL: #{url.inspect}"
    else
      if Dir["#{attachment_directory}/*"].empty?
        log "Downloading: #{url} to #{attachment_directory}"
        `cd #{attachment_directory} && wget -q --content-disposition "#{url}"`
        unless $?.success?
          log "Failed to download #{url}"
        end
      else
        log "Skipping #{url}, as at least one file already exists in #{attachment_directory}"
      end
    end
  end
end

def process_filetypes(directory)
  Dir["#{directory}/**/*"].select { |p| File.file?(p) }.each do |original_path|
    next if File.basename(original_path) == "metadata.json"
    path = ensure_utf8(original_path)
    FileUtils.mv(original_path, path) unless original_path == path
    file_type = `file -e cdf -b "#{path}"`.strip
    case file_type
    when /^PDF /
      FileUtils.mv(path, path + ".pdf") if File.extname(path) == ""
    when /^HTML /
      log "deleting #{path}"
      FileUtils.rm_rf(path)
    else
      log "UNKNOWN FILE: #{path}" if File.extname(path) == ""
    end
  end
end

require 'iconv'

def ensure_utf8(str)
  ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
  ic.iconv(str + ' ')[0..-2]
end

def create_publications(csv_data, download_directory, creator, organisation)
  PaperTrail.whodunnit = creator

  log "Creating publications"
  csv_data.each_with_index do |row, index|
    log "Generating '#{row["Title"]}'"
    publication_attributes = {
      state: "draft",
      creator: creator,
      title: row["Title"],
      body: row["Body"],
      publication_date: Date.parse(row["Date"]),
      publication_type: PublicationType::Unknown,
      organisations: [organisation],
      alternative_format_provider: organisation
    }
    publication = Publication.new(publication_attributes)
    if publication.save
      log "\tCreated publication #{publication.id} (#{index}/#{csv_data.length})"
      url = row["Attachment"]
      if url && url.strip != ''
        attachment_path = Dir[File.join(download_directory, attachment_directory_for(url), "*")].first
        if attachment_path
          metadata_path = File.join(download_directory, attachment_directory_for(url), "metadata.json")
          File.open(metadata_path, "w") do |f|
            f.write ActiveSupport::JSON.encode(
              publication_id: publication.id,
              title: row["Filename"],
              order_url: row["Order URL"],
              price: row["Price"],
              unique_reference: row["URN"]
            )
          end
          log "\tStored publication ID against attachment for later processing: #{metadata_path}"
        else
          log "\tNo attachment downloaded; skipping ID"
        end
      else
        log "\tNo attachment URL."
      end
    else
      log "\tCouldn't save publication:"
      log publication.errors.full_messages
    end
  end
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
        edition_attachment = EditionAttachment.new(
          edition_id: metadata["publication_id"],
          attachment_attributes: {
            file: File.open(attachment_path),
            title: metadata["title"],
            order_url: metadata["order_url"],
            price: metadata["price"],
            unique_reference: metadata["unique_reference"]
          }
        )
        if edition_attachment.save
          log "\tAdded attachment data from #{attachment_directory}"
        else
          log "\tCouldn't save attachment:"
          log edition_attachment.errors.full_messages
        end
      end
    else
      log "\tNo attachment data in #{attachment_directory}"
    end
  end
end

csv_data = CSV.parse(File.read(csv_filename), headers: true)

log "Downloading pending attachments"
attachment_urls = csv_data.map { |r| r["Attachment"] }.reject { |url| url.nil? || url.strip == '' }
download_attachments(download_directory, attachment_urls)
log "Processing attachment files"
process_filetypes(download_directory)

create_publications(csv_data, download_directory, user, bis)
create_attachments(download_directory)
