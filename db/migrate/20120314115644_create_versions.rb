class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.string   :item_type, null: false
      t.integer  :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
      t.text     :state
    end
    execute %q{
    insert into versions (item_type, item_id, event, whodunnit, created_at) 
    select 'Document', id, 'create', (select user_id from document_authors where document_authors.document_id=documents.id order by created_at desc limit 1), created_at from documents
    }
    execute %q{
    insert into versions (item_type, item_id, event, whodunnit, created_at) 
    select 'Document', d1.document_id, 'update', d1.user_id, d1.created_at from document_authors d1 where id != (select id from document_authors d2 where d2.document_id=d1.document_id order by created_at asc limit 1);
    }
    add_index :versions, [:item_type, :item_id]
  end

  def self.down
    remove_index :versions, [:item_type, :item_id]
    drop_table :versions
  end
end
