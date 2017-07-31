module SyncChecker
  module Checks
    HtmlAttachmentUnpublishedCheck = Struct.new(:attachment) do
      attr_reader :attachable, :content_item, :unpublishing, :response

      def call(response)
        @attachable = attachment.attachable
        @unpublishing = attachable.unpublishing
        @response = response

        failures = []
        return failures unless attachable.unpublishing.present?

        if there_is_an_item_in_the_content_store?
          begin
            @content_item = JSON.parse(response.body)
            if attachable_has_been_withdrawn?
              failures << check_for_withdrawn_notice
            elsif attachable_has_been_unpublished?
              failures << check_redirected
            end
          rescue JSON::ParserError
            failures << "response.body not valid JSON. Likely not present in the content store"
          end
        else
          failures << "attachable has been unpublished but the attachment has nothing in the content store"
        end
        failures.compact
      end

      private

      def there_is_an_item_in_the_content_store?
        response.body != ""
      end

      def attachable_has_been_withdrawn?
        attachable.withdrawn?
      end

      def check_for_withdrawn_notice
        item_withdrawn_explanation = content_item["withdrawn_notice"]["explanation"]
        return if unpublishing.explanation.blank? && item_withdrawn_explanation.blank?

        withdrawn_explanation = Whitehall::GovspeakRenderer.new.govspeak_to_html(unpublishing.explanation)

        if !EquivalentXml.equivalent?(withdrawn_explanation, item_withdrawn_explanation)
          "expected withdrawn notice: '#{withdrawn_explanation}' but got '#{item_withdrawn_explanation}'"
        end
      end

      def attachable_has_been_unpublished?
        attachable.draft? && unpublishing.present?
      end

      def check_redirected
        if attachable_should_be_redirected_to_parent?
          check_for_redirect_to_parent
        else
          check_for_redirect_to_alternative_url
        end
      end

      def attachable_should_be_redirected_to_parent?
        unpublishing.unpublishing_reason_id == UnpublishingReason::PUBLISHED_IN_ERROR_ID &&
          !unpublishing.redirect?
      end

      def check_for_redirect_to_parent
        "attachment should redirect to parent" unless content_item["schema_name"] == "redirect"
      end

      def check_for_redirect_to_alternative_url
        "attachment should redirect to the 'https://gov.uk/alt'" unless content_item["schema_name"] == "redirect"
      end

      def unpublishing
        attachable.unpublishing
      end
    end
  end
end
