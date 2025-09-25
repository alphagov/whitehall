module Presenters
  module PublishingApi
    module RenderedAttachmentsHelper
      def render_attachments(attachments = [])
        attachments
          .select { |attachment| !attachment.file? || attachment.attachment_data.all_asset_variants_uploaded? }
          .map do |attachment|
          ApplicationController.renderer.render(
            template: "govuk_publishing_components/components/_attachment",
            locals: {
              attachment: attachment.publishing_component_params,
              margin_bottom: 6,
            },
          )
        end
      end
    end
  end
end
