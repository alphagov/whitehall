module Govspeak
  class RemoveAdvisoryService
    attr_reader :body

    def initialize(object, dry_run: true)
      @object = object
      @body = object.body || object.govspeak_content.body
      @whodunnit = User.find_by(name: "GDS Inside Government Team")
      @dry_run = dry_run
    end

    def process!
      if @dry_run
        matches = find_all_advisories(body)
        puts "\n[DRY RUN] Advisory changes detected for #{@object.title}, (ID: #{@object.id}):"
        puts "belongs to #{@object.attachable.title}" if @object.is_a?(HtmlAttachment)
        puts "----------------------------------"
        matches.each do |match|
          puts "Old advisory:\n#{match[:old]}"
          puts "New advisory:\n#{match[:new]}"
          puts "----------------------------------"
        end
        return
      end
      if @object.is_a?(Edition)
        AuditTrail.acting_as(@whodunnit) do
          # Create a new draft of the edition
          draft = @object.create_draft(@whodunnit)

          # Replace advisories in the body of the edition
          new_body = replace_all_advisories(body)

          # Update the draft edition with the new body and set to minor change
          draft.update!(
            body: new_body,
            minor_change: true,
          )
          submit_and_publish!(draft)
        end
      elsif @object.is_a?(HtmlAttachment)
        AuditTrail.acting_as(@whodunnit) do
          # Create a draft of the edition the attachment belongs to
          draft = @object.attachable.create_draft(@whodunnit)

          # Find the relevant attachment in the new draft
          new_attachment = draft.html_attachments.find_by(slug: @object.slug)

          # Replace advisories in the body of the new attachment
          new_body = replace_all_advisories(new_attachment.body)
          new_attachment.govspeak_content.update!(body: new_body)

          # Set the owning draft edition to be a minor change
          draft.update!(minor_change: true)
          submit_and_publish!(draft)
        end
      else
        raise "Unsupported object type: #{@object.class.name}"
      end
    end

    def submit_and_publish!(draft)
      # Submit the draft so it is ready to be published
      draft.submit!

      # Add a reason for force publishing
      publish_reason = "Replacing deprecated advisory elements with information callouts"

      # Publish the edition
      edition_publisher = Whitehall.edition_services.publisher(draft, user: @whodunnit, remark: publish_reason)
      edition_publisher.perform!
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
      Govspeak::EmbeddedContentPatterns::ADVISORY.to_s
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

    def find_all_advisories(body_content)
      matches = []
      body_content.scan(regexp_for_advisory_markup) do |opening_at, content_after_at, closing_at|
        old = closing_at.present? ? "#{opening_at}#{content_after_at}#{closing_at}" : "#{opening_at}#{content_after_at}"
        new = information_calloutify(content_after_at)
        matches << { old: old, new: new }
      end
      matches
    end
  end
end
