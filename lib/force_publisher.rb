# This can be used to force publish all documents for a particular organisation
class ForcePublisher
  include Admin::EditionRoutesHelper
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

  attr_reader :failures, :successes

  def initialize(acronym, options = {})
    @acronym = acronym
    @organisation = Organisation.find_by_acronym!(acronym)
    @failures = []
    @successes = []
    @excluded_types = options[:excluded_types] ? [*options[:excluded_types]] : []
  end

  def excluded_types
    @excluded_types.map do |type_name|
      Object.const_get(type_name)
    end
  end

  def editions_to_publish(limit = nil)
    editions = @organisation.editions
      .draft
      .latest_edition
      .where("exists (select * from document_sources ds where ds.document_id=editions.document_id)")
      .limit(limit)
    if excluded_types.any?
      editions.where("type not in (?)", excluded_types.map(&:name))
    else
      editions
    end
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
    editions_to_publish(limit).each do |edition|
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
end