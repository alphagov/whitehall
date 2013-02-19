class RenameInternationalPriorityToWorldwidePriority < ActiveRecord::Migration
  def up
    execute "UPDATE editions SET type = 'WorldwidePriority' WHERE type = 'InternationalPriority'"
    execute "UPDATE documents SET document_type = 'WorldwidePriority' WHERE document_type = 'InternationalPriority'"
  end

  def down
    execute "UPDATE editions SET type = 'InternationalPriority' WHERE type = 'WorldwidePriority'"
    execute "UPDATE documents SET document_type = 'InternationalPriority' WHERE document_type = 'WorldwidePriority'"
  end
end
