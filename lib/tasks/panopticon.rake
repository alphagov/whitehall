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
      registerer.register(artefact)
    end
  end
end
