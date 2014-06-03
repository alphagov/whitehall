module Whitehall::Wait
  def until(timestamp, &_block)
    while timestamp > Time.zone.now
      sleep(timestamp - Time.zone.now)
    end
    yield
  end

  module_function :until
end
