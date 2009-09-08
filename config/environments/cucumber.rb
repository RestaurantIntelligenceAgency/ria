config.cache_classes = true # This must be true for Cucumber to operate correctly!
::RANDOM_SQL_STRING = 'RANDOM()'
# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test
DEFAULT_HOST = 'localhost:3000'

config.gem "rspec", :lib => false, :version => '>=1.2.8' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec'))
config.gem "rspec-rails", :lib => false, :version => '>=1.2.7' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
config.gem "webrat", :lib => false, :version => '>=0.5.3' unless File.directory?(File.join(Rails.root, 'vendor/plugins/webrat'))
config.gem "cucumber", :lib => false, :version => '>=0.3.98' unless File.directory?(File.join(Rails.root, 'vendor/plugins/cucumber'))
config.gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
config.gem 'bmabey-email_spec', :lib => 'email_spec', :source => "http://gems.github.com", :version => ">= 0.3.1"
config.gem "fakeweb", :version => ">= 1.2.5"
config.gem "mocha"
