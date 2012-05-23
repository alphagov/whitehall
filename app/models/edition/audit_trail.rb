module Edition::AuditTrail
  extend ActiveSupport::Concern

  included do
    has_paper_trail meta: {state: :state}
  end

  def audit_trail
    doc_identity.editions.order("created_at asc").map.with_index do |edition, i|
      versions = edition.versions.map { |v|
        VersionAuditEntry.new(i, edition, v)
      }
      editorial_remarks = edition.editorial_remarks.map { |r|
        EditorialRemarkAuditEntry.new(i, edition, r)
      }
      (versions + editorial_remarks).sort
    end.flatten
  end

  class AuditEntry

    attr_reader :edition_serial_number, :edition

    def initialize(edition_serial_number, edition)
      @edition_serial_number = edition_serial_number
      @edition = edition
    end

    def <=>(other)
      if created_at == other.created_at
        sort_priority <=> other.sort_priority
      else
        created_at <=> other.created_at
      end
    end

    def ==(other)
      @edition_serial_number == other.edition_serial_number && @edition == other.edition
    end

    def first_edition?
      @edition_serial_number == 0
    end

    def sort_priority; 0; end
  end

  class VersionAuditEntry < AuditEntry
    extend Forwardable

    attr_reader :version

    def_delegators :@version, :created_at

    def initialize(edition_serial_number, edition, version)
      super(edition_serial_number, edition)
      @version = version
    end

    def sort_priority; 3; end

    def ==(other)
      other.class == self.class && super(other) && version == other.version
    end

    def event
      previous_state = @version.previous && @version.previous.state
      case @version.event
      when "create"
        first_edition? ? "create" : "edition"
      when "delete"
        @version.event
      else
        previous_state != @version.state ? make_present_tense(@version.state) : "update"
      end
    end

    def actor
      @version.whodunnit && User.find(@version.whodunnit)
    end

    private

    def make_present_tense(event)
      event.gsub(/t?ted$/, 't').gsub(/ed$/, '')
    end

  end

  class EditorialRemarkAuditEntry < AuditEntry
    extend Forwardable
    attr_reader :editorial_remark

    def_delegators :@editorial_remark, :created_at

    def initialize(edition_serial_number, edition, editorial_remark)
      super(edition_serial_number, edition)
      @editorial_remark = editorial_remark
    end

    def event
      "editorial_remark"
    end

    def actor
      @editorial_remark.author
    end

    def message
      @editorial_remark.body
    end

    def sort_priority; 2; end

    def ==(other)
      other.class == self.class && super(other) && editorial_remark == other.editorial_remark
    end
  end
end
