module Admin::AdminGovspeakHelper
  include GovspeakHelper

  def govspeak_to_admin_html(govspeak, images = [], attachments = [], alternative_format_contact_email = nil)
    images = prepare_images(images)
    attachments = prepare_attachments(attachments, alternative_format_contact_email)
    wrapped_in_govspeak_div(bare_govspeak_to_admin_html(govspeak, images, attachments))
  end

  def govspeak_edition_to_admin_html(edition)
    images = prepare_images(edition.try(:images) || [])

    # some Edition types don't allow attachments to be embedded in body content
    attachments = if edition.allows_inline_attachments?
                    prepare_attachments(edition.attachments, edition.alternative_format_contact_email)
                  else
                    []
                  end

    wrapped_in_govspeak_div(bare_govspeak_to_admin_html(edition.body, images, attachments))
  end

  def bare_govspeak_to_admin_html(govspeak, images = [], attachments = [])
    bare_govspeak_to_html(govspeak, images, attachments) do |replacement_html, edition|
      latest_edition = edition && edition.document.latest_edition
      if latest_edition.nil?
        replacement_html = tag.del(replacement_html)
        explanation = state = "deleted"
      else
        state = latest_edition.state
        explanation = link_to(state, admin_edition_path(latest_edition))
      end

      tag.span class: "#{state}_link" do
        annotation = tag.sup(safe_join(["(", explanation, ")"]), class: "explanation")
        safe_join [replacement_html, annotation], " "
      end
    end
  end
end
