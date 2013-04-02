module Whitehall::Wait
  def until(timestamp, &block)
    time_slept = 0
    time_to_sleep = timestamp - Time.zone.now

    while time_slept < time_to_sleep
       time_slept += sleep(time_to_sleep)
    end
    yield
  end

  module_function :until
end
