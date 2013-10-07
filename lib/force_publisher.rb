# This can be used to force publish all documents for a particular organisation
class ForcePublisher
  attr_reader :failures, :successes, :editions_to_publish

  def initialize(editions_to_publish)
    @failures = []
    @successes = []
    @editions_to_publish = editions_to_publish
  end

  class Worker
    def user
      @user ||= User.find_by_name!("GDS Inside Government Team")
    end

    def force_publish!(editions, reporter)
      editions.each do |edition|
        if edition.nil?
          reporter.failure(edition, 'Edition is nil')
        else
          if reason = edition.reason_to_prevent_force_publication
            reporter.failure(edition, reason)
          else
            begin
              Edition::AuditTrail.acting_as(user) do
                edition.perform_force_publish
              end
              reporter.success(edition)
            rescue => e
              reporter.failure(edition, e)
            end
          end
        end
      end
    end
  end

  def force_publish!(limit = nil)
    suppress_logging!
    editions = limit ? @editions_to_publish.take(limit) : @editions_to_publish
    Worker.new.force_publish!(editions, self)
  end

  def suppress_logging!
    ActiveRecord::Base.logger = Logger.new(Rails.root.join("log/force_publish.log"))
  end

  def success(edition)
    puts "OK : #{edition.id}: https://www.gov.uk#{Whitehall.url_maker.public_document_path(edition)}"
    @successes << edition
  end

  def failure(edition, reason)
    puts "ERR: #{edition.id unless edition.nil?}: #{reason.to_s}"
    @failures << [edition, reason]
  end

  def self.for_import(import_instance_or_id)
    import = import_instance_or_id.is_a?(Import) ? import_instance_or_id : Import.find(import_instance_or_id)
    raise "import #{import.id} status is #{import.status}, but only successful imports can be published" unless import.status == :succeeded
    editions_to_publish = import.document_sources.map do |ds|
      ds.document.latest_edition
    end
    ForcePublisher.new(editions_to_publish)
  end

  def self.for_organisation(acronym, options = {})
    organisation = Organisation.find_by_acronym!(acronym)
    excluded_types = (options[:excluded_types] ? [*options[:excluded_types]] : []).map do |type_name|
      Object.const_get(type_name)
    end
    editions_to_publish = organisation.editions
      .draft
      .latest_edition
      .where("exists (select * from document_sources ds where ds.document_id=editions.document_id)")
    if excluded_types.any?
      editions_to_publish = editions_to_publish.where("type not in (?)", excluded_types.map(&:name))
    end
    ForcePublisher.new(editions_to_publish)
   end
end
