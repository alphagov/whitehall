module DelayedJobTestHelpers
  def self.without_delay!
    Delayed::Worker.delay_jobs = false
    begin
      yield
    ensure
      Delayed::Worker.delay_jobs = true
    end
  end

  def without_delay!
    DelayedJobTestHelpers.without_delay! do
      yield
    end
  end

  def assert_indexed_for_search(model)
    search_job = Searchable::Index.new(model.class.name, model.id)

    assert Delayed::Job.exists?(["handler = ?", YAML.dump(search_job)]),
      "Could not find search indexing job for #{model.class.name} with ID #{model.id}"
  end

  def assert_deleted_from_search_index(model)
    delete_job = Searchable::Delete.new(model.public_path, model.rummager_index)

    assert Delayed::Job.exists?(["handler = ?", YAML.dump(delete_job)]),
      "Could not find search delete job for #{model.class.name} with ID #{model.id}"
  end
end
