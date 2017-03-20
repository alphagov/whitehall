require 'test_helper'

class PublishingApiCorporateInformationPagesWorkerTest < ActiveSupport::TestCase
  def assert_document_republished(document_id)
    PublishingApiDocumentRepublishingWorker
      .expects(:perform_async)
      .with(document_id)

    event = self.class.name.demodulize.underscore

    PublishingApiCorporateInformationPagesWorker
      .new
      .perform(
        corporate_information_page.id,
        event,
      )
  end

  def about_page
    @about_page ||= create(
      :about_corporate_information_page,
      organisation: organisation,
    )
  end

  def corporate_information_page
    create(:corporate_information_page, organisation: organisation)
  end

  def organisation
    @organisation ||= create(:organisation)
  end

  class Delete < PublishingApiCorporateInformationPagesWorkerTest
    test 'it republishes the corresponding about page' do
      assert_document_republished about_page.document_id
    end
  end

  class ForcePublish < PublishingApiCorporateInformationPagesWorkerTest
    test 'it republishes the corresponding about page' do
      assert_document_republished about_page.document_id
    end
  end

  class Publish < PublishingApiCorporateInformationPagesWorkerTest
    test 'it republishes the corresponding about page' do
      assert_document_republished about_page.document_id
    end
  end

  class Republish < PublishingApiCorporateInformationPagesWorkerTest
    test 'it republishes the corresponding about page' do
      assert_document_republished about_page.document_id
    end
  end

  class Unpublish < PublishingApiCorporateInformationPagesWorkerTest
    test 'it republishes the corresponding about page' do
      assert_document_republished about_page.document_id
    end
  end

  class Unwithdraw < PublishingApiCorporateInformationPagesWorkerTest
    test 'it republishes the corresponding about page' do
      assert_document_republished about_page.document_id
    end
  end

  class UpdateDraft < PublishingApiCorporateInformationPagesWorkerTest
    test 'it republishes the corresponding about page' do
      assert_document_republished about_page.document_id
    end
  end

  class UpdateDraftTranslation < PublishingApiCorporateInformationPagesWorkerTest
    test 'it republishes the corresponding about page' do
      assert_document_republished about_page.document_id
    end
  end

  class Withdraw < PublishingApiCorporateInformationPagesWorkerTest
    test 'it republishes the corresponding about page' do
      assert_document_republished about_page.document_id
    end
  end
end
