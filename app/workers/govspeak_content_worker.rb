class GovspeakContentWorker
  include Sidekiq::Worker

  def perform(id)
    return unless govspeak_content = GovspeakContent.find_by(id: id)

    govspeak_content.computed_body_html = generate_govspeak(govspeak_content)
    govspeak_content.computed_headers_html = generate_headers(govspeak_content)
    govspeak_content.save!
  end

private

  def generate_govspeak(govspeak_content)
    body = govspeak_content.body
    options = govspeak_options(govspeak_content)
    if govspeak_content.html_attachment.attachable.respond_to?(:images)
      images = govspeak_content.html_attachment.attachable.images
    else
      images = []
    end

    helpers.govspeak_to_html(body, images, options)
  end

  def generate_headers(govspeak_content)
    helpers.html_attachment_govspeak_headers_html(govspeak_content.html_attachment)
  end

  def govspeak_options(govspeak_content)
    method = govspeak_content.manually_numbered_headings? ? :manual : :auto
    { heading_numbering: method, contact_heading_tag: 'h4' }
  end

  # Because the govspeak helpers in whitehall rely on rendering partials, we
  # need to make sure the view paths are set, otherwise the helpers can't find
  # the partials.
  def helpers
    @helpers ||= begin
      helpers = ApplicationController.helpers
      helpers.view_paths = ApplicationController.view_paths
      helpers
    end
  end
end
