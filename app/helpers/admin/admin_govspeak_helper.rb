module Admin::AdminGovspeakHelper
  include GovspeakHelper

  def govspeak_to_admin_html(govspeak, images = [], attachments = [], alternative_format_contact_email = nil)
    partially_processed_govspeak = govspeak_with_attachments_and_alt_format_information(govspeak, attachments, alternative_format_contact_email)
    wrapped_in_govspeak_div(bare_govspeak_to_admin_html(partially_processed_govspeak, images))
  end

  def govspeak_edition_to_admin_html(edition)
    images = edition.respond_to?(:images) ? edition.images : []
    partially_processed_govspeak = edition_body_with_attachments_and_alt_format_information(edition)
    wrapped_in_govspeak_div(bare_govspeak_to_admin_html(partially_processed_govspeak, images))
  end

  def bare_govspeak_to_admin_html(govspeak, images = [], _attachments = [])
    govspeak = remove_extra_quotes_from_blockquotes(govspeak)
    bare_govspeak_to_html(govspeak, images) do |replacement_html, edition|
      latest_edition = edition && edition.document.latest_edition
      if latest_edition.nil?
        replacement_html = content_tag(:del, replacement_html)
        explanation = state = "deleted"
      else
        state = latest_edition.state
        explanation = link_to(state, admin_edition_path(latest_edition))
      end

      content_tag :span, class: "#{state}_link" do
        annotation = content_tag(:sup, safe_join(['(', explanation, ')']), class: 'explanation')
        safe_join [replacement_html, annotation], ' '
      end
    end
  end
end
