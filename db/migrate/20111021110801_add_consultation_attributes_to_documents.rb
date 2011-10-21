class AddConsultationAttributesToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :opening_on, :date
    add_column :documents, :closing_on, :date
  end
end
