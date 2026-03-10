if Rails.application.config.active_storage.service == :r2 && !ENV["SECRET_KEY_BASE_DUMMY"]
  required_keys = %i[access_key_id secret_access_key bucket endpoint_url]
  env = Rails.env.to_sym
  s3_config = Rails.application.credentials.dig(:s3, env)

  if s3_config.nil?
    raise "Missing S3 credentials for #{Rails.env} environment. " \
          "Run `bin/rails credentials:edit` and add the :s3 -> :#{env} section."
  end

  missing = required_keys.select { |key| s3_config[key].blank? }
  if missing.any?
    raise "Missing S3 credential keys for #{Rails.env}: #{missing.join(', ')}. " \
          "Run `bin/rails credentials:edit` to add them under :s3 -> :#{env}."
  end
end
