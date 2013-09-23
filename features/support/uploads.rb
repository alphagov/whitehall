# Blow away the incoming/clean test uploads for this env to avoid clashes during test run
require File.dirname(__FILE__) + "/../../test/support/virus_scan_helpers"
VirusScanHelpers.erase_test_files
