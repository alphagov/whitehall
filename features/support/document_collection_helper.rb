module DocumentCollectionStepHelpers
  def assert_document_is_part_of_document_collection(document_title)
    within '#document_collection' do
      assert page.has_content? document_title
    end
  end

  def refute_document_is_part_of_document_collection(document_title)
    within '#document_collection' do
      refute page.has_content? document_title
    end
  end
end

World(DocumentCollectionStepHelpers)
