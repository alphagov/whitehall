require "mocha/minitest"

World(Mocha::API)

Before do
  mocha_setup
end

After do
  begin
    mocha_verify
  ensure
    mocha_teardown
  end
end
