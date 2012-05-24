require 'rails/test_help'

if ActiveSupport::VERSION::STRING == "3.1.3" && MiniTest::Unit::VERSION == "2.5.1"
  module ActiveSupport::Testing::SetupAndTeardown::ForMiniTest
    PASSTHROUGH_EXCEPTIONS = MiniTest::Unit::TestCase::PASSTHROUGH_EXCEPTIONS

    def run(runner)
      result = '.'
      begin
        run_callbacks :setup do
          result = super
        end
      rescue *PASSTHROUGH_EXCEPTIONS
        raise
      rescue Exception => e
        result = runner.puke(self.class, method_name, e)
      ensure
        begin
          run_callbacks :teardown
        rescue *PASSTHROUGH_EXCEPTIONS
          raise
        rescue Exception => e
          result = runner.puke(self.class, method_name, e)
        end
      end
      result
    end
  end
else
  warn "Ignoring 'allow interrupt during MiniTest run' patch since it has not been tested with this version of ActiveSupport & MiniTest and it monkey-patches ForMiniTest#run which in turn monkey-patches MiniTest::Unit::TestCase#run and the relevant code may have changed."
end
