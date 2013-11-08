require 'addressable/uri'

class EditionTranslation < ActiveRecord::Base
  belongs_to :edition

  def state
    edition.try(:state) || 'deleted'
  end
end
EditionTranslation.table_name = :edition_translations

$csv_data = {
  nonadmin_paths: [],
  relative_admin_paths: [],
  absolute_admin_urls: [],
  nonadmin_preview_links: [],
  probably_ok_links: [],
  possibly_broken_links: []
}

def replace_link_if_required(link_type, body, edition_translation, original_link = nil, replacement_link = nil)
  puts "Replacing #{link_type.to_s.humanize.downcase.singularize} '#{original_link}' with '#{replacement_link}' in edition ##{edition_translation.edition_id}"

  row_data = {
    edition: edition_translation.edition_id,
    state: edition_translation.state,
    original: original_link || '(NULL)',
    replacement: replacement_link || '(NULL)'
  }

  if replacement_link.nil? && (edition = edition_translation.edition)
    row_data.merge!(
      admin_link: "https://whitehall-admin.production.alphagov.co.uk/government/admin/editions/#{edition.id}",
      force_published: edition.force_published?
    )
  end

  $csv_data[link_type] << row_data

  if replacement_link
    body.gsub(original_link, replacement_link)
  else
    body
  end
end

EditionTranslation.includes(:edition).
where("editions.state NOT IN ('deleted', 'superseded', 'archived')
       AND edition_translations.body LIKE '%[%'").find_each do |et|
  body = et.body
  new_body = nil

  et.body.scan(/\[.*?\]\((\S*?)(:?\s+"[^"]+")?\)/) do |capture_groups|
    original_link = capture_groups.first || 'NULL'
    body = new_body || body

    if original_link.first == '/' # We have a path
      unless original_link.start_with?("#{Whitehall.router_prefix}/admin")
        replace_link_if_required(:nonadmin_paths, body, et, original_link) # Not fixing
      end
    else # We have a URL
      begin
        parsed_original_link = Addressable::URI.parse(original_link)
      rescue Addressable::URI::InvalidURIError
        # Not fixing
        replace_link_if_required(:possibly_broken_links, body, et, original_link)
        next
      end

      new_body = if "/#{original_link}".start_with?("#{Whitehall.router_prefix}/admin")
        replace_link_if_required(:relative_admin_paths, body, et, original_link, "/#{original_link}")

      elsif parsed_original_link.path.start_with?("#{Whitehall.router_prefix}/admin")
        replace_link_if_required(:absolute_admin_urls, body, et, original_link, parsed_original_link.path)

      elsif original_link =~ /whitehall-admin/
        replace_link_if_required(:nonadmin_preview_links, body, et, original_link, parsed_original_link.path)

      elsif original_link =~ %r{^(https?://|mailto:|#)}
        replace_link_if_required(:probably_ok_links, body, et, original_link) # Not fixing

      elsif original_link =~ /^www/
        replace_link_if_required(:possibly_broken_links, body, et, original_link, "http://#{original_link}")

      elsif original_link =~ /@/
        replace_link_if_required(:possibly_broken_links, body, et, original_link, "mailto:#{original_link}")

      elsif original_link =~ /^http;(.+)/
        replace_link_if_required(:possibly_broken_links, body, et, original_link, "http:#{$1}")

      else
        replace_link_if_required(:possibly_broken_links, body, et, original_link) # Not fixing
      end
    end
  end

  et.update_column(:body, new_body) if new_body
end

csv_dir = Pathname.new('tmp/link_csvs')
csv_dir.mkpath

headers = [:edition, :state, :original, :replacement, :admin_link, :force_published]
$csv_data.each do |link_type, links|
  csv_path = csv_dir+"#{link_type}.csv"
  puts "Building #{csv_path}"
  File.open(csv_path, 'w') do |file|
    file.puts headers.join(',')

    links.each do |link_data|
      file.puts link_data.slice(*headers).values.join(',')
    end
  end
end
