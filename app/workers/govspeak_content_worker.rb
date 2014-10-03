class GovspeakContentWorker
  include Sidekiq::Worker

  def perform(id)
    govspeak_content = GovspeakContent.find(id)
    govspeak_content.computed_html = generate_govspeak(govspeak_content)
    govspeak_content.save!
  end

private

  def generate_govspeak(govspeak_content)
    body = govspeak_content.body
    options = govspeak_options(govspeak_content.html_attachment)
    if govspeak_content.html_attachment.attachable.respond_to?(:images)
      images = govspeak_content.html_attachment.attachable.images
    else
      images = []
    end

    ApplicationController.helpers.govspeak_to_html(body, images, options)
  end

  def govspeak_options(attachment)
    numbering_method = attachment.manually_numbered_headings? ? :manual : :auto

    { heading_numbering: numbering_method, contact_heading_tag: 'h4' }
  end
end
