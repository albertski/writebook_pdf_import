ENV["RAILS_ENV"] ||= "test"
require_relative "../test/dummy/config/environment"
require "rails/test_help"

# Load the schema into the in-memory database
ActiveRecord::Schema.verbose = false
load File.expand_path("../test/dummy/db/schema.rb", __dir__)

# Point file_fixture_path to the gem's test/fixtures/files directory
ActiveSupport::TestCase.file_fixture_path = File.expand_path("../test/fixtures/files", __dir__)

ActiveSupport::TestCase.fixture_paths = [ File.expand_path("../test/fixtures", __dir__) ]

module ActiveSupport
  class TestCase
    fixtures :all
  end
end
