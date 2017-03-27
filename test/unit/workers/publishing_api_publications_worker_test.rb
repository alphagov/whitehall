require 'test_helper'

class PublishingApiPublicationsWorkerTest < ActiveSupport::TestCase
  def about_pages
    @about_pages ||= organisations.collect do |organisation|
      create(:about_corporate_information_page, organisation: organisation)
    end
  end

  def about_page_document_ids
    @about_page_document_ids ||= about_pages.map(&:document_id)
  end

  def organisations
    @organisations ||= create_list(:organisation, 2)
  end

  def call(publication_trait = nil)
    publication = create(:publication, publication_trait,
                         organisations: organisations)

    PublishingApiPublicationsWorker
      .new
      .perform(
        publication.id,
        'delete',
      )
  end

  class Publish < PublishingApiPublicationsWorkerTest
    test 'it republishes the corresponding about page when related' do
      about_page_document_ids
        .each { |document_id|
          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async)
            .with(document_id)
        }

      call :foi_release
    end

    test 'it does not republish the corresponding about page when unrelated' do
      about_page_document_ids
        .each { |document_id|
          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async)
            .with(document_id)
            .never
        }

      call :statistics
    end
  end

  class Delete < PublishingApiPublicationsWorkerTest
    test 'it republishes the corresponding about page' do
      about_page_document_ids
        .each { |document_id|
          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async)
            .with(document_id)
        }

      call :foi_release
    end
  end

  class ForcePublish < PublishingApiPublicationsWorkerTest
    test 'it republishes the corresponding about page' do
      about_page_document_ids
        .each { |document_id|
          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async)
            .with(document_id)
        }

      call :foi_release
    end
  end

  class Republish < PublishingApiPublicationsWorkerTest
    test 'it republishes the corresponding about page' do
      about_page_document_ids
        .each { |document_id|
          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async)
            .with(document_id)
        }

      call :foi_release
    end
  end

  class Unpublish < PublishingApiPublicationsWorkerTest
    test 'it republishes the corresponding about page' do
      about_page_document_ids
        .each { |document_id|
          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async)
            .with(document_id)
        }

      call :foi_release
    end
  end

  class Unwithdraw < PublishingApiPublicationsWorkerTest
    test 'it republishes the corresponding about page' do
      about_page_document_ids
        .each { |document_id|
          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async)
            .with(document_id)
        }

      call :foi_release
    end
  end

  class UpdateDraft < PublishingApiPublicationsWorkerTest
    test 'it republishes the corresponding about page' do
      about_page_document_ids
        .each { |document_id|
          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async)
            .with(document_id)
        }

      call :foi_release
    end
  end

  class UpdateDraftTranslation < PublishingApiPublicationsWorkerTest
    test 'it republishes the corresponding about page' do
      about_page_document_ids
        .each { |document_id|
          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async)
            .with(document_id)
        }

      call :foi_release
    end
  end

  class Withdraw < PublishingApiPublicationsWorkerTest
    test 'it republishes the corresponding about page' do
      about_page_document_ids
        .each { |document_id|
          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async)
            .with(document_id)
        }

      call :foi_release
    end
  end
end
