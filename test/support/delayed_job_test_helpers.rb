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
end
