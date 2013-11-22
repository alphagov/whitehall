require 'addressable/uri'
require 'logger'

class BadMarkdownLinkCleaner
  attr_reader :csv_data

  def initialize(options = {})
    @logger = options[:logger] || Logger.new(nil)
    @router_prefix = options[:router_prefix] || Whitehall.router_prefix
    @actor = options[:actor] || User.find_by_name!('GDS Inside Government Team')

    @csv_data = {
      nonadmin_paths: [],
      relative_admin_paths: [],
      absolute_admin_urls: [],
      nonadmin_preview_links: [],
      probably_ok_links: [],
      possibly_broken_links: []
    }
  end

  def clean!(edition_translation)
    new_body = replacement_body_for(edition_translation)

    if new_body
      edition_translation.update_column(:body, new_body)
    end
  end

  def replacement_body_for(edition_translation)
    body = edition_translation.body
    new_body = nil

    edition_translation.body.scan(/(\[(.*?)\]\((\S*?)(\s+"[^"]+")?\))/) do |capture_groups|
      original_markdown, original_text, original_link, original_title = capture_groups
      body = new_body || body

      if original_link.first == '/' # We have a path
        unless original_link.start_with?("#{@router_prefix}/admin")
          replace_link_if_required(:nonadmin_paths, body, edition_translation, original_markdown) # Not fixing
        end
      else # We have a URL
        begin
          parsed_original_link = Addressable::URI.parse(original_link)
        rescue Addressable::URI::InvalidURIError
          # Not fixing
          replace_link_if_required(:possibly_broken_links, body, edition_translation, original_markdown)
          next
        end

        new_body = if "/#{original_link}".start_with?("#{@router_prefix}/admin")
          new_link = "/#{original_link}"
          replace_link_if_required(:relative_admin_paths, body, edition_translation, original_markdown, "[#{original_text}](#{new_link}#{original_title})")
        elsif parsed_original_link.path.start_with?("#{@router_prefix}/admin")
          new_link = parsed_original_link.path
          replace_link_if_required(:absolute_admin_urls, body, edition_translation, original_markdown, "[#{original_text}](#{new_link}#{original_title})")
        elsif original_link =~ /whitehall-admin/

          new_link = parsed_original_link.dup
          new_link.host = "www.gov.uk"
          new_link.scheme = "https"
          if new_link.query_values
            new_link.query_values = parsed_original_link.query_values.reject {|k,v| %w{cachebust preview}.include?(k)}
            new_link.query_values = nil if new_link.query_values.empty?
          end
          replace_link_if_required(:nonadmin_preview_links, body, edition_translation, original_markdown, "[#{original_text}](#{new_link}#{original_title})")
        elsif original_link =~ %r{^(https?://|mailto:|#)}
          replace_link_if_required(:probably_ok_links, body, edition_translation, original_markdown) # Not fixing
        elsif original_link =~ /^www/
          new_link = "http://#{original_link}"
          replace_link_if_required(:possibly_broken_links, body, edition_translation, original_markdown, "[#{original_text}](#{new_link}#{original_title})")
        elsif original_link =~ /@/
          new_link = "mailto:#{original_link}"
          replace_link_if_required(:possibly_broken_links, body, edition_translation, original_markdown, "[#{original_text}](#{new_link}#{original_title})")
        elsif original_link =~ /^http;(.+)/
          new_link = "http:#{$1}"
          replace_link_if_required(:possibly_broken_links, body, edition_translation, original_markdown, "[#{original_text}](#{new_link}#{original_title})")
        else
          replace_link_if_required(:possibly_broken_links, body, edition_translation, original_markdown) # Not fixing
        end
      end
    end

    new_body
  end

private
  def replace_link_if_required(link_type, body, edition_translation, original_markdown, replacement_markdown = nil)
    if replacement_markdown
      @logger.info "Replacing #{link_type.to_s.humanize.downcase.singularize} '#{original_markdown}' with '#{replacement_markdown}' in edition ##{edition_translation.edition_id}"
    else
      @logger.info "Not replacing #{link_type.to_s.humanize.downcase.singularize} '#{original_markdown}' in edition ##{edition_translation.edition_id}"
    end

    row_data = {
      edition: edition_translation.edition_id,
      state: edition_translation.state,
      original: original_markdown || '(NULL)',
      replacement: replacement_markdown || '(NULL)'
    }

    if replacement_markdown.nil? && (edition = edition_translation.edition)
      row_data.merge!(
        admin_link: "https://whitehall-admin.production.alphagov.co.uk/government/admin/editions/#{edition.id}",
        force_published: edition.force_published?
      )
    end

    @csv_data[link_type] << row_data

    if replacement_markdown
      editorial_remark = "Replaced #{link_type.to_s.humanize.downcase.singularize} '#{original_markdown}' with '#{replacement_markdown}' during data migration 20131106163843"
      edition_translation.edition.editorial_remarks.create(author: @actor, body: editorial_remark)

      body.gsub(original_markdown, replacement_markdown)
    else
      body
    end
  end

end