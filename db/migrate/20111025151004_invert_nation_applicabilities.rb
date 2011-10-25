class InvertNationApplicabilities < ActiveRecord::Migration

  def change
    create_table :nation_inapplicabilities, force: true do |t|
      t.references :nation
      t.references :document
      t.timestamps
    end
    add_exclusions_for_all_documents_and_nations
    remove_exclusions_for_documents_with_applicable_nations
    drop_table :nation_applicabilities
  end

  def add_exclusions_for_all_documents_and_nations
    insert %{
      INSERT INTO nation_inapplicabilities (nation_id, document_id, created_at, updated_at)
        SELECT nations.id, documents.id, NOW(), NOW()
          FROM documents
          LEFT OUTER JOIN nations ON 1 = 1
          WHERE documents.type = 'Policy'
    }
  end

  def remove_exclusions_for_documents_with_applicable_nations
    delete %{
      DELETE nation_inapplicabilities FROM nation_inapplicabilities
        INNER JOIN nation_applicabilities
          ON nation_applicabilities.document_id = nation_inapplicabilities.document_id
            AND nation_applicabilities.nation_id = nation_inapplicabilities.nation_id;
    }
  end

end
