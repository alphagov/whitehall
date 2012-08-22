# encoding: UTF-8
require 'csv'
require 'fileutils'

csv_filename = ARGV.shift
unless csv_filename && File.exists?(csv_filename)
  puts "Usage: script/rails r #{__FILE__} /path/to/publications.csv"
  exit 1
end

def log(message)
  puts message
end

def download_attachments(directory, urls)
  urls.reject { |u| u.nil? || u.strip == "" || u =~ /createsend/ }.each.with_index do |url, index|
    attachment_directory = "#{directory}/#{index}"
    FileUtils.mkdir_p(attachment_directory)
    if Dir["#{attachment_directory}/*"].empty?
      log "Downloading: #{url} to #{attachment_directory}"
      `cd #{attachment_directory} && wget -q --content-disposition #{url}`
      unless $?.success?
        log "Failed to download #{url}"
      end
    else
      # log "Skipping #{url}, file already exists in #{attachment_directory}"
    end
  end
end

def process_filetypes(directory)
  Dir["#{directory}/**/*"].select { |p| File.file?(p) }.each do |path|
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

base_directory = "public/system/tmp_bis_publications"

csv_data = CSV.readlines(csv_filename, headers: true)

log "Downloading pending attachments"
download_attachments(base_directory, csv_data.map { |r| r["Attachment"] })
log "Processing attachment files"
process_filetypes(base_directory)

bis = Organisation.find_by_acronym("BIS")
user = User.find_by_name("Automatic Data Importer")
PaperTrail.whodunnit = user

log "Creating publications"
csv_data.each_with_index do |row, index|
  log "\tGenerating '#{row["Title"]}'"
  publication_attributes = {
    state: "draft",
    creator: user,
    title: row["Title"],
    body: row["Body"],
    publication_date: Date.parse(row["Date"]),
    publication_type: PublicationType::Unknown,
    organisations: [bis],
    alternative_format_provider: bis
  }
  attachment_path = Dir[File.join(base_directory, index.to_s, "*")].first
  if attachment_path
    attachment_attributes = {
      file: File.open(attachment_path),
      title: row["Filename"],
      order_url: row["Order URL"],
      price: row["Price"],
      unique_reference: row["URN"]
    }
    publication_attributes[:edition_attachments_attributes] = {"0" => {attachment_attributes: attachment_attributes}}
    log "\tadded attachment data"
  else
    log "\tno attachment data in #{File.join(base_directory, index.to_s)}"
  end
  publication = Publication.new(publication_attributes)
  if publication.save
    log "Created publication #{publication.id} (#{index}/#{csv_data.length})"
  else
    log "Couldn't save publication:"
    log publication.errors.full_messages
  end
end