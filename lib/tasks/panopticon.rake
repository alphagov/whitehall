require 'ostruct'

namespace :panopticon do
  require 'gds_api/panopticon'

  desc "Register application metadata with Panopticon"
  task :register => :environment do
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }

    registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: 'whitehall-frontend')
    logger.info "Registering application with Panopticon..."

    record = OpenStruct.new(
      slug: 'government',
      title: "Departments and Policy",
      description: "All government department and organisation corporate publishing",
      prefixes: ['/government'],
      state: 'live',
      indexable_content: "Departments and Policy")
    registerer.register(record)
  end

  desc "Register detailed guides with Panopticon"
  task :register_guidance => :environment do
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering detailed guides with Panopticon..."
    registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: 'whitehall-frontend', kind: 'detailed_guide')

    DetailedGuide.published.includes(:document, :primary_mainstream_category, :other_mainstream_categories).each do |guide|
      artefact = RegisterableEdition.new(guide)
      logger.info "Registering /#{guide.slug} with Panopticon..."
      begin
        registerer.register(artefact)
      rescue GdsApi::HTTPErrorResponse => e
        logger.error "Failed to register /#{guide.slug} with #{e.code}: #{e.error_details}"
      end
    end
  end

  desc "Register all content for a specialist sector with Panopticon"
  task :register_specialist_sector_content => :environment do
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }

    unless ENV["TAG"].present?
      logger.error "Please provide a value for TAG in the environment."
    end
    tag_id_fragment = ENV["TAG"]

    # use a fuzzy match so that "oil-and-gas" will also include child tags like "oil-and-gas/fields-and-wells"
    edition_ids = SpecialistSector.where("tag LIKE ?", "#{tag_id_fragment}%").map(&:edition_id)

    published_editions = Edition.published.where(id: edition_ids)
    logger.info "Found #{published_editions.count} published editions with tag #{tag_id_fragment}"

    published_editions.each do |edition|
      artefact = RegisterableEdition.new(edition)
      registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: 'whitehall-frontend', kind: artefact.kind)
      logger.info "Registering /#{artefact.slug} with Panopticon..."

      begin
        registerer.register(artefact)
      rescue GdsApi::HTTPErrorResponse => e
        logger.error "Failed to register /#{edition.slug} with #{e.code}: #{e.error_details}"
      end
    end
  end
end
