# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

  # Never send cookies: the signed session_id cookie is a bearer credential.
  # (data_collection replaces the deprecated send_default_pii in sentry-ruby 7;
  # user info, headers, and bodies keep its default deny-list filtering.)
  config.data_collection.cookies = false
end
