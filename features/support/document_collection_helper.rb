module DocumentCollectionStepHelpers
  def assert_document_is_part_of_document_collection(document_title)
    if @user.can_remove_edit_tabs?
      within ".document-row" do
        expect(page).to have_content(document_title)
      end
    else
      within ".tab-content" do
        expect(page).to have_content(document_title)
      end
    end
  end

  def refute_document_is_part_of_document_collection(document_title)
    within ".tab-content" do
      expect(page).to_not have_content(document_title)
    end
  end
end

World(DocumentCollectionStepHelpers)
