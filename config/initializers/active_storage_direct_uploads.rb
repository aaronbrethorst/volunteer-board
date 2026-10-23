# Active Storage's direct-upload endpoint (used by Trix) is public by default,
# which lets anyone create blobs and get signed upload URLs to the bucket.
# Require a signed-in user. This is a JSON endpoint inside the Active Storage
# engine, so answer with 401 rather than redirecting to the sign-in page.
Rails.application.config.to_prepare do
  ActiveStorage::DirectUploadsController.before_action do
    session_id = cookies.signed[:session_id]
    head :unauthorized unless session_id && Session.active.exists?(id: session_id)
  end
end
