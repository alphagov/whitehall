# This can be used to force publish all documents for a particular organisation
class ForcePublisher
  include Admin::EditionRoutesHelper
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

  attr_reader :failures, :successes, :editions_to_publish

  def initialize(editions_to_publish)
    @failures = []
    @successes = []
    @editions_to_publish = editions_to_publish
  end

  def user
    @user ||= User.find_by_name!("GDS Inside Government Team")
  end

  def acting_as(user)
    old_user, PaperTrail.whodunnit = PaperTrail.whodunnit, user
    yield
    PaperTrail.whodunnit = old_user
  end

  def suppress_logging!
    ActiveRecord::Base.logger = Logger.new(Rails.root.join("log/force_publish.log"))
  end

  def force_publish!(limit = nil)
    suppress_logging!
    editions = limit ? @editions_to_publish.take(limit) : @editions_to_publish
    editions.each do |edition|
      reason = edition.reason_to_prevent_publication_by(user, force: true)
      if reason
        failure(edition, reason)
      else
        begin
          acting_as(user) do
            edition.publish_as(user, force: true)
          end
          success(edition)
        rescue => e
          failure(edition, e)
        end
      end
    end
  end

  def success(edition)
    puts "OK : #{edition.id}: https://www.gov.uk#{public_document_path(edition)}"
    @successes << edition
  end

  def failure(edition, reason)
    puts "ERR: #{edition.id}: #{reason.to_s}"
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