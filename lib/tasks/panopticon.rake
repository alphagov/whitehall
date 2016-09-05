require 'ostruct'
require "data_hygiene/registerable_edition_builder_for_unpublished_editions"

namespace :panopticon do
  require 'gds_api/panopticon'

  desc "Register application metadata with Panopticon"
  task :register => :environment do
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }

    registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND)
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
    registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND, kind: 'detailed_guide')

    Document.where(document_type: "DetailedGuide").published.each do |document|
      guide = document.published_edition
      artefact = RegisterableEdition.new(guide)
      logger.info "Registering /#{guide.slug} with Panopticon..."
      begin
        registerer.register(artefact)
      rescue GdsApi::HTTPErrorResponse => e
        logger.error "Failed to register /#{guide.slug} with #{e.code}: #{e.error_details}"
      end
    end
  end

  desc "Re-register unpublished content with Panopticon"
  task :re_register_unpublished_content => :environment do
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build

    registerable_editions.each do |registerable_edition|
      registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND, kind: registerable_edition.kind)

      begin
        logger.info "About to register #{registerable_edition.edition.id}"
        registerer.register(registerable_edition)
        logger.info "Re-registered as \"#{registerable_edition.state}\" - /#{registerable_edition.slug}"
      rescue GdsApi::HTTPErrorResponse => e
        logger.error "Failed to re-register /#{registerable_edition.slug} with #{e.code}: #{e.error_details}"
      end
    end
  end

  desc "Re-register published editions with Panopticon"
  task :re_register_published_editions => :environment do
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }

    documents = Document.all.published

    unregistered_documents = []

    documents.find_each do |document|

      if edition = document.published_edition
        artefact = RegisterableEdition.new(edition)
        registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND, kind: artefact.kind)
        logger.info "Registering /#{artefact.slug} with Panopticon..."

        begin
          registerer.register(artefact)
        rescue GdsApi::HTTPErrorResponse => e
          logger.error "Failed to register /#{edition.slug} with #{e.code}: #{e.error_details}"
          unregistered_documents << "#{edition.slug}, error code: #{e.code}, error details: #{e.error_details}"
        rescue StandardError => e
          logger.error "Failed to register /#{edition.slug}, error: #{e}"
          unregistered_documents << "#{edition.slug}, error: #{e}"
        end
      end
    end

    puts
    puts "*******************************"
    puts "Slugs of unregistered documents along with the errors:"
    puts unregistered_documents
  end
end
