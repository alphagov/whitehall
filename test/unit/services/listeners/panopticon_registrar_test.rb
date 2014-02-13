require 'test_helper'

class ServiceListeners::PanopticonRegistrarTest < ActiveSupport::TestCase

  test "registers a DetailedGuide with panopticon" do
    edition = create(:published_detailed_guide)
    PanopticonRegisterArtefactWorker.expects(:perform_async).with(edition.id).once
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end

  test "registers a Consultation with panopticon" do
    edition = create(:published_consultation)
    PanopticonRegisterArtefactWorker.expects(:perform_async).with(edition.id).once
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end

  test "registers a Publication with panopticon" do
    edition = create(:published_publication)
    PanopticonRegisterArtefactWorker.expects(:perform_async).with(edition.id).once
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end

  test "registers a DocumentCollection with panopticon" do
    edition = create(:published_document_collection)
    PanopticonRegisterArtefactWorker.expects(:perform_async).with(edition.id).once
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end

  test "registers a Policy with panopticon" do
    edition = create(:published_policy)
    PanopticonRegisterArtefactWorker.expects(:perform_async).with(edition.id).once
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end

  test "registers a StatisticalDataSet with panopticon" do
    edition = create(:published_statistical_data_set)
    PanopticonRegisterArtefactWorker.expects(:perform_async).with(edition.id).once
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end

  test "does not register other document types" do
    edition = build(:published_news_article)
    PanopticonRegisterArtefactWorker.expects(:perform_async).never
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end
end
