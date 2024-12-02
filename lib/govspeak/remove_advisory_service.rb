module Govspeak
  class RemoveAdvisoryService

    attr_reader :body

    def initialize(object)
      @body = object.body
    end

    def process!
      new_body = replace_all_advisories(body)
      unless new_body == body
        record.update!(body: new_body)
      end
    end

    def replace_all_advisories(body_content)
      match = advisory_match_group(body_content)
      return body_content if match.nil?

      new_body = replace_advisory_with_information_callout(match, body_content)
      replace_all_advisories(new_body)
    end

    def advisory_match_group(body_content)
      matchdata = body_content.match(regexp_for_advisory_markup)
      return unless matchdata
      {
        opening_at: matchdata[1],
        content_after_at: matchdata[2],
        closing_at: matchdata[3],
        other_possible_line_ends: matchdata[4],
      }
    end

    def regexp_for_advisory_markup
      opening_at = '(^@)'
      content_after_at = '([\s\S]*?)'
      closing_at = '(@?)'
      other_possible_line_ends = '(?:^\$CTA|\r?\n\r?\n|^@|$)'
      Regexp.new(opening_at + content_after_at + closing_at + '(?=' + other_possible_line_ends + ')', Regexp::MULTILINE)
    end

    def replace_advisory_with_information_callout(match, body_content)
      if match[:closing_at].present?
        string_to_modify = match[:opening_at] + match[:content_after_at] + match[:closing_at]
      else
        string_to_modify = match[:opening_at] + match[:content_after_at]
      end

      body_content.gsub(string_to_modify, information_calloutify(match[:content_after_at]))
    end

    def information_calloutify(string)
      "^#{string}^"
    end

  private
    # If I understand it correctly, we don't need this method as we are not going to be handling drafts that contatin advisory markup.
    def create_minor_update(new_body)
      if object.is_a?(Edition)
        AuditTrail.acting_as(whodunnit) do
          draft = object.create_draft(whodunnit)
          draft.update!(
            body: new_body,
            minor_change: true,
          )
          draft.submit!
          publish_reason = "Replacing deprecated advisory elements with information callouts"
          edition_publisher = Whitehall.edition_services.publisher(draft, user: @whodunnit, remark: publish_reason)
          edition_publisher.perform!
        end
      elsif object.is_a?(HtmlAttachment)
        object.update!(body: new_body)

        AuditTrail.acting_as(whodunnit) do
          draft = object.attachable.create_draft(whodunnit)
          draft.update!(
            minor_change: true,
          )
          draft.submit!
          publish_reason = "Replacing deprecated advisory elements with information callouts"
          edition_publisher = Whitehall.edition_services.publisher(draft, user: @whodunnit, remark: publish_reason)
          edition_publisher.perform!
        end
      else
        raise "Unsupported object type: #{object.class.name}"
      end
    end
  end
end
