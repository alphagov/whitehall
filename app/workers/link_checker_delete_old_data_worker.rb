class LinkCheckerDeleteOldDataWorker < WorkerBase
  def perform
    Whitehall::Application.load_tasks
    Rake::Task["link_checker:delete_old_data"].invoke
  end
end
