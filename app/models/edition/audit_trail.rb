module Edition::AuditTrail
  extend ActiveSupport::Concern

  included do
    has_paper_trail meta: {state: :state}
  end

  def edition_audit_trail(edition_serial_number = 1)
    versions = self.versions.map { |v|
      VersionAuditEntry.new(edition_serial_number, self, v)
    }
    editorial_remarks = self.editorial_remarks.map { |r|
      EditorialRemarkAuditEntry.new(edition_serial_number, self, r)
    }
    (versions + editorial_remarks).sort
  end

  def audit_trail
    document.editions.order("created_at asc").map.with_index do |edition, i|
      edition.edition_audit_trail(i)
    end.flatten
  end

  def last_audit_trail_version_event(state)
    edition_audit_trail.reverse.find { |at| at.respond_to?(:version) && at.version.state == state }
  end

  class AuditEntry
    extend ActiveModel::Naming

    delegate :created_at, :to_key, to: :@object

    attr_reader :edition_serial_number, :edition, :object

    def initialize(edition_serial_number, edition, object)
      @edition_serial_number = edition_serial_number
      @edition = edition
      @object = object
    end

    def <=>(other)
      if created_at == other.created_at
        sort_priority <=> other.sort_priority
      else
        created_at <=> other.created_at
      end
    end

    def ==(other)
      other.class == self.class &&
      other.edition_serial_number == edition_serial_number &&
      other.edition == edition &&
      other.object == object
    end

    def first_edition?
      edition_serial_number == 0
    end

    def sort_priority; 0; end
  end

  class VersionAuditEntry < AuditEntry
    class << self
      def model_name
        ActiveModel::Name.new(Version, nil)
      end
    end

    alias_method :version, :object

    def sort_priority; 3; end

    def event
      previous_state = version.previous && version.previous.state
      case version.event
      when "create"
        first_edition? ? "create" : "edition"
      when "delete"
        version.event
      else
        previous_state != version.state ? make_present_tense(version.state) : "update"
      end
    end

    def actor
      if User.exists?(version.whodunnit)
        User.find(version.whodunnit)
      else
        nil # for deleted users
      end
    end

    private

    def make_present_tense(event)
      case event.downcase
      when 'published' then 'publish'
      when 'rejected' then 'reject'
      when 'submitted' then 'submit'
      when 'deleted' then 'delete'
      else
        event
      end
    end
  end

  class EditorialRemarkAuditEntry < AuditEntry
    class << self
      def model_name
        ActiveModel::Name.new(EditorialRemark, nil)
      end
    end

    alias_method :editorial_remark, :object

    def event
      "editorial_remark"
    end

    def actor
      editorial_remark.author
    end

    def message
      editorial_remark.body
    end

    def sort_priority; 2; end
  end
end
