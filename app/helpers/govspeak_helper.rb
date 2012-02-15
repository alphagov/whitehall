module GovspeakHelper

  def govspeak_to_admin_html(text, images = [])
    markup_to_html_with_replaced_admin_links(text, images) do |replacement_html, document|
      latest_edition = document && document.document_identity.latest_edition
      if latest_edition.nil?
        replacement_html = content_tag(:del, replacement_html)
        explanation = state = "deleted"
      else
        state = latest_edition.state
        explanation = link_to(state, admin_document_path(latest_edition))
      end

      content_tag :span, class: "#{state}_link" do
        annotation = content_tag(:sup, safe_join(['(', explanation, ')']), class: 'explanation')
        safe_join [replacement_html, annotation], ' '
      end
    end
  end

  def govspeak_to_html(text, images = [])
    markup_to_html_with_replaced_admin_links(text, images)
  end

  def govspeak_headers(text, level = 2)
    Govspeak::Document.new(text).headers.each do |header|
      header.level == level
    end
  end

  private

  def markup_to_html_with_replaced_admin_links(text, images = [], &block)
    markup_to_nokogiri_doc(text, images).tap do |nokogiri_doc|
      replace_internal_admin_links_in nokogiri_doc, &block
    end.to_html.html_safe
  end

  def replace_internal_admin_links_in(nokogiri_doc)
    nokogiri_doc.search('a').each do |anchor|
      next unless is_internal_admin_link?(uri = anchor['href'])

      document, supporting_page = find_documents_from_uri(uri)
      replacement_html = replacement_html_for(anchor, document, supporting_page)
      replacement_html = yield(replacement_html, document) if block_given?

      anchor.replace Nokogiri::HTML.fragment(replacement_html)
    end
  end

  def replacement_html_for(anchor, document, supporting_page)
    if document.present? && document.linkable?
      anchor.dup.tap do |anchor|
        anchor['href'] = rewritten_href_for_documents(document, supporting_page)
      end.to_html.html_safe
    else
      anchor.inner_text
    end
  end

  def markup_to_nokogiri_doc(text, images = [])
    govspeak = Govspeak::Document.new(text).tap { |g| g.images = images }
    html = content_tag(:div, govspeak.to_html.html_safe, class: 'govspeak')
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "UTF-8"
    doc.fragment(html)
  end

  def is_internal_admin_link?(href)
    begin
      uri = Addressable::URI.parse(href)
    rescue Addressable::URI::InvalidURIError
      return false
    end

    return false unless %w(http https).include?(uri.scheme)
    truncated_link_uri = [normalise_host(uri.host), uri.path.split("/")[1,2]].join("/")
    truncated_host_uri = [normalise_host(request.host) + Whitehall.router_prefix, "admin"].join("/")
    truncated_link_uri == truncated_host_uri
  end

  def find_documents_from_uri(uri)
    id = uri[/\/([^\/]+)$/, 1]
    if uri =~ /\/supporting\-pages\//
      begin
        supporting_page = SupportingPage.find(id)
      rescue ActiveRecord::RecordNotFound
        supporting_page = nil
      end
      if supporting_page
        document = supporting_page.document
      else
        document = nil
      end
    else
      document = Document.send(:with_exclusive_scope) do
        begin
          Document.find(id)
        rescue ActiveRecord::RecordNotFound
          nil
        end
      end
      supporting_page = nil
    end
    [document, supporting_page]
  end

  def rewritten_href_for_documents(document, supporting_page)
    if supporting_page
      public_supporting_page_url(document, supporting_page)
    else
      public_document_url(document)
    end
  end

  def normalise_host(host)
    Whitehall.public_host_for(host) || host
  end
end