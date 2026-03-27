require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)
require "writebook_pdf_import"

module Dummy
  class Application < Rails::Application
    config.root = File.expand_path("..", __dir__)
    config.load_defaults 8.0
    config.action_mailer.default_url_options = { host: "localhost" }
  end
end
