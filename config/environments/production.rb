Ria::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  # config.serve_static_assets = false
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug
  config.action_mailer.delivery_method = :sendmail

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Settings specified here will take precedence over those in config/environment.rb
  DEFAULT_HOST = 'spoonfeed.restaurantintelligenceagency.com'

  # Full error reports are disabled and caching is turned on
  config.action_view.cache_template_loading            = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  config.cache_store = :mem_cache_store, "localhost:11211", { :namespace => "prod" }

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  Braintree::Configuration.environment = :production
  Braintree::Configuration.merchant_id = "3fb27hjyr2pj4mkh"
  Braintree::Configuration.public_key = "8946tj2vb98yf6xq"
  Braintree::Configuration.private_key = "tkjvt5wph2m5qh33"

  config.action_mailer.delivery_method = :sendmail

  CLOUDMAIL_ID = '0df080edd37d5e209f5d'
  CLOUDMAIL_DOMAIN = 'mailbot.restaurantintelligenceagency.com'
  # for verifying the emails came from cloudmailin
  CLOUDMAIL_SECRET = '781ff8e2b62535e0eee2'.freeze

  ENV['MAILCHIMP_API_KEY'] = 'b992d9bf14db221d322b7add975b1c39-us2'
  DOMAIN_NAME = "restaurantintelligenceagency.com"
end
