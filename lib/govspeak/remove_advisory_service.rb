module Govspeak
  class RemoveAdvisoryService
    attr_reader :object, :regex, :whodunnit

    def initialize(object, regex, whodunnit = User.find_by(name: "GDS Inside Government Team"))
      @object = object
      @regex = regex
      @whodunnit = whodunnit
    end

    def process!
      body = object.body
      matches = body.scan(regex)
      return if matches.empty?

      new_body = body.gsub(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m) do
        content = Regexp.last_match(1)
        "^#{content}^"
      end
      if new_body != body
        record.update!(body: new_body)
      end
    end

  private

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
