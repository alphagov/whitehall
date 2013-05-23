module Edition::AuditTrail
  extend ActiveSupport::Concern

  class << self
    attr_accessor :whodunnit

    def acting_as(actor)
      original_actor, Edition::AuditTrail.whodunnit = Edition::AuditTrail.whodunnit, actor
      yield
    ensure
      Edition::AuditTrail.whodunnit = original_actor
    end
  end

  included do
    has_many :versions, as: :item, order: "created_at ASC, id ASC"

    after_create  :record_create
    before_update :record_update
  end

  def record_create
    versions.create event: 'create', whodunnit: Edition::AuditTrail.whodunnit, state: state
  end
  private :record_create

  def record_update
    if changed.any?
      versions.build event: 'update', whodunnit: Edition::AuditTrail.whodunnit, state: state
    end
  end
  private :record_update

  def edition_audit_trail(edition_serial_number = 0)
    versions = edition_version_trail(edition_serial_number)
    remarks = edition_remarks_trail(edition_serial_number)
    (versions + remarks).sort
  end

  def edition_remarks_trail(edition_serial_number = 0)
    self.editorial_remarks.map { |r|
      EditorialRemarkAuditEntry.new(edition_serial_number, self, r)
    }.sort
  end

  def edition_version_trail(edition_serial_number = 0)
    self.versions.map { |v|
      VersionAuditEntry.new(edition_serial_number, self, v)
    }.sort
  end

  def document_audit_trail
    document.editions.includes(versions: [:user], editorial_remarks: [:author]).order("created_at asc").map.with_index do |edition, i|
      edition.edition_audit_trail(i)
    end.flatten
  end

  def document_remarks_trail
    document.editions.includes(editorial_remarks: [:author]).order("created_at asc").map.with_index do |edition, i|
      edition.edition_remarks_trail(i)
    end.flatten
  end

  def document_version_trail
    document.editions.includes(versions: [:user]).order("created_at asc").map.with_index do |edition, i|
      edition.edition_version_trail(i)
    end.flatten
  end


  def latest_version_audit_entry_for(state)
    edition_version_trail.reverse.detect { |audit_entry| audit_entry.version.state == state }
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
        if sort_priority = other.sort_priority
          object <=> other.object
        else
          sort_priority <=> other.sort_priority
        end
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

    def sort_priority
      0
    end
  end

  class VersionAuditEntry < AuditEntry
    class << self
      def model_name
        ActiveModel::Name.new(Version, nil)
      end
    end

    alias_method :version, :object

    def sort_priority; 3; end

    def action
      previous_state = version.previous && version.previous.state
      case version.event
      when "create"
        first_edition? ? "created" : "editioned"
      else
        previous_state != version.state ? version.state : "updated"
      end
    end

    def actor
      version.user
    end
  end

  class EditorialRemarkAuditEntry < AuditEntry
    class << self
      def model_name
        ActiveModel::Name.new(EditorialRemark, nil)
      end
    end

    alias_method :editorial_remark, :object

    def action
      "editorial_remark"
    end

    def actor
      editorial_remark.author
    end

    def message
      editorial_remark.body
    end

    def sort_priority
      2
    end
  end
end
