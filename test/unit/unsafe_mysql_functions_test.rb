require 'test_helper'

class UnsafeMySQLFunctionsTest < ActiveSupport::TestCase
  def unsafe_functions
    %w{
      FOUND_ROWS()
      GET_LOCK()
      IS_FREE_LOCK()
      IS_USED_LOCK()
      LOAD_FILE()
      MASTER_POS_WAIT()
      RAND()
      RELEASE_LOCK()
      ROW_COUNT()
      SESSION_USER()
      SLEEP()
      SYSDATE()
      SYSTEM_USER()
      USER()
      UUID()
      UUID_SHORT()
    }
  end

  def unsafe_function_regex
    escaped_functions = unsafe_functions.map { |function| Regexp.escape(function) }
    Regexp.new(
      "(" +
        escaped_functions.join("|") +
      ")",
      Regexp::IGNORECASE
    )
  end

  test "no (suspected) uses of MySQL functions which are unsafe with statement-based replication" do
    files = Dir.glob(File.join(Rails.root, '**', '*.rb'))
    bad_files = files.select do |filename|
      next if filename == File.expand_path(__FILE__)

      match = false
      File.open(filename) do |file|
        match = file.grep(unsafe_function_regex).any?
      end
      match
    end

    # This test is case insensitive so has the potential to return false
    # positives. If it does return a false positive, you might:
    #
    #   * remove the parentheses from the Ruby method call
    #   * tweak this test - eg we're unlikely to call MySQL's USER() function,
    #     but we might call current_user() in our code
    #
    # For more details: http://dev.mysql.com/doc/refman/5.5/en/replication-rbr-safe-unsafe.html
    message = "Found suspected calls to MySQL functions which are unsafe with statement-based replication."
    assert_equal [], bad_files, message
  end
end
