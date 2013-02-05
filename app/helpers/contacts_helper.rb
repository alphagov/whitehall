module ContactsHelper
  def render_hcard(contact, &block)
    return unless contact.has_postal_address?
    content_tag(:div, class: "vcard") do
      content_tag(:div, class: "adr") do
        hcard_lines(
          ["note", contact.comments],
          ["fn", contact.recipient],
          ["street-address", format_with_html_line_breaks(contact.street_address)],
          ["locality", contact.locality],
          ["region", contact.region],
          ["postal-code", contact.postal_code],
          ["country-name", contact.country && contact.country.name]
        )
      end + (block_given? ? capture(&block) : "")
    end
  end

  def hcard_lines(*lines)
    non_empty = lines.reject {|line| line[1].blank?}
    non_empty.map do |css_class, line|
      content_tag(:span, line, class: css_class)
    end.join("<br />".html_safe).html_safe
  end
end