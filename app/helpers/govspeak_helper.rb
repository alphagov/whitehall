module GovspeakHelper

  def govspeak_to_admin_html(text)
    doc = markup_to_nokogiri_doc(text)

    replace_internal_admin_links_in(doc) do |replacement_html, document|
      latest_edition = document && document.document_identity.latest_edition
      if latest_edition.nil?
        replacement_html = "<del>#{replacement_html}</del>"
        explanation = state = "deleted"
      else
        state = latest_edition.state
        explanation = %{<a href="#{admin_document_path(latest_edition)}">#{state}</a>}
      end

      %{<span class="#{state}_link">#{replacement_html} <sup class="explanation">(#{explanation})</sup></span>}
    end

    doc.to_html.html_safe
  end

  def govspeak_to_html(text)
    doc = markup_to_nokogiri_doc(text)
    replace_internal_admin_links_in doc
    doc.to_html.html_safe
  end

  def govspeak_headers(text, level = 2)
    Govspeak::Document.new(text).headers.each do |header|
      header.level == level
    end
  end

  private

  def replace_internal_admin_links_in(nokogiri_doc)
    nokogiri_doc.search('a').each do |anchor|
      next unless is_internal_admin_link?(uri = anchor['href'])

      document, supporting_page = find_documents_from_uri(uri)
      if document.present? && document.linkable?
        anchor['href'] = rewritten_href_for_documents(document, supporting_page)
        replacement_html = anchor.to_html
      else
        replacement_html = anchor.inner_text
      end

      anchor.replace Nokogiri::HTML.fragment(replacement_html)
    end
  end

  def markup_to_nokogiri_doc(text)
    govspeak = Govspeak::Document.to_html(text)
    html = '<div class="govspeak">' + govspeak + '</div>'
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "UTF-8"
    doc.fragment(html)
  end

  def is_internal_admin_link?(href)
    uri = URI.parse(href)
    return false unless %w(http https).include?(uri.scheme)
    truncated_link_uri = [uri.host, uri.path.split("/")[1,2]].join("/")
    truncated_host_uri = [request.host + Whitehall.router_prefix, "admin"].join("/")
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
    if host = Whitehall.public_host_for(request.host)
      if supporting_page
        policy_supporting_page_url(document, supporting_page, host: host)
      else
        public_document_url(document, host: host)
      end
    else
      if supporting_page
        policy_supporting_page_path(document, supporting_page)
      else
        public_document_path(document)
      end
    end
  end
end