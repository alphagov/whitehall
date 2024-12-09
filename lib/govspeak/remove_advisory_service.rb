module Govspeak
  class RemoveAdvisoryService
    attr_reader :body

    def initialize(object)
      @object = object
      @body = object.body || object.govspeak_content.body
      @whodunnit = User.find_by(name: "GDS Inside Government Team")
    end

    def process!
      if @object.is_a?(Edition)
        AuditTrail.acting_as(@whodunnit) do

          # Create a new draft of the edition
          draft = @object.create_draft(@whodunnit)

          # Replace advisories in the body of the new attachment
          new_body = replace_all_advisories(body)

          # Update the draft edition and publish
          draft.update!(
            body: new_body,
            minor_change: true,
          )
          draft.submit!
          publish_reason = "Replacing deprecated advisory elements with information callouts"
          edition_publisher = Whitehall.edition_services.publisher(draft, user: @whodunnit, remark: publish_reason)
          edition_publisher.perform!
        end
      elsif @object.is_a?(HtmlAttachment)
        AuditTrail.acting_as(@whodunnit) do
          # Create a draft of the attachable edition
          draft = @object.attachable.create_draft(@whodunnit)

          # Find the attachment in the new draft
          new_attachment = draft.html_attachments.find_by(slug: @object.slug)

          # Replace advisories in the body of the new attachment
          new_body = replace_all_advisories(new_attachment.body)
          new_attachment.govspeak_content.update!(body: new_body)

          # Update the draft edition and publish
          draft.update!(minor_change: true)
          draft.submit!
          publish_reason = "Replacing deprecated advisory elements with information callouts"
          edition_publisher = Whitehall.edition_services.publisher(
            draft,
            user: @whodunnit,
            remark: publish_reason,
          )
          edition_publisher.perform!
        end
      else
        raise "Unsupported object type: #{@object.class.name}"
      end
    end

    def replace_all_advisories(body_content)
      match = advisory_match_group(body_content)
      return body_content if match.nil?

      new_body = replace_advisory_with_information_callout(match, body_content)
      replace_all_advisories(new_body)
    end

    def advisory_match_group(body_content)
      match_data = body_content.match(regexp_for_advisory_markup)
      return unless match_data

      {
        opening_at: match_data[1],
        content_after_at: match_data[2],
        closing_at: match_data[3],
        other_possible_line_ends: match_data[4],
      }
    end

    def regexp_for_advisory_markup
      opening_at = "(^@)"
      content_after_at = '([\s\S]*?)'
      closing_at = "(@?)"
      other_possible_line_ends = '(?:^\$CTA|\r?\n\r?\n|^@|$)'
      Regexp.new("#{opening_at}#{content_after_at}#{closing_at}(?=#{other_possible_line_ends})", Regexp::MULTILINE)
    end

    def replace_advisory_with_information_callout(match, body_content)
      string_to_modify = if match[:closing_at].present?
                           match[:opening_at] + match[:content_after_at] + match[:closing_at]
                         else
                           match[:opening_at] + match[:content_after_at]
                         end

      body_content.gsub(string_to_modify, information_calloutify(match[:content_after_at]))
    end

    def information_calloutify(string)
      "^#{string}^"
    end
  end
end
