# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data, "https://fonts.gstatic.com"

    # Allow Active Storage images served from Cloudflare R2
    r2_endpoint = Rails.application.credentials.dig(:s3, Rails.env.to_sym, :endpoint_url)
    r2_bucket = Rails.application.credentials.dig(:s3, Rails.env.to_sym, :bucket)
    r2_host = if r2_endpoint && r2_bucket
      uri = URI.parse(r2_endpoint)
      "https://#{r2_bucket}.#{uri.host}"
    end
    policy.img_src     :self, :data, :blob, *[ r2_host ].compact

    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self, :unsafe_inline, "https://fonts.googleapis.com"
    policy.connect_src :self
    policy.frame_src   :none
    policy.base_uri    :self
    policy.form_action :self, "https://github.com/login/oauth/authorize", "https://www.linkedin.com/oauth/"
  end

  # Generate session nonces for permitted importmap and inline scripts.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
end
