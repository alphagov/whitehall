module DocumentCollectionStepHelpers
  def assert_document_is_part_of_document_collection(document_title)
    within '.tab-content' do
      assert_text document_title
    end
  end

  def refute_document_is_part_of_document_collection(document_title)
    within '.tab-content' do
      assert_no_text document_title
    end
  end
end

World(DocumentCollectionStepHelpers)
