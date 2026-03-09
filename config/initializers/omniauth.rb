Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
    Rails.application.credentials.dig(:github, :client_id),
    Rails.application.credentials.dig(:github, :client_secret),
    scope: "user:email"

  provider :linkedin,
    Rails.application.credentials.dig(:linkedin, :client_id),
    Rails.application.credentials.dig(:linkedin, :client_secret),
    scope: "openid profile email"
end

OmniAuth.config.allowed_request_methods = [ :post ]
