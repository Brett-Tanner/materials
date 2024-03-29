# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
# Add additional requires below this line. Rails is not loaded until this point!
require 'rspec/rails'
require 'capybara/rspec'
require 'database_cleaner-active_record'
# Require all support files
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  # Manage test data with DatabaseCleaner
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Allow short versions of FactoryBot methods
  config.include FactoryBot::Syntax::Methods

  # Use route and Devies helpers in request specs
  config.include Rails.application.routes.url_helpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Use Rack::Test by default for system specs
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :request) do
    default_url_options[:locale] = I18n.default_locale
  end

  config.before(:each, :js, type: :system) do
    driven_by :selenium_chrome_headless
    default_url_options[:locale] = I18n.default_locale
  end
end
