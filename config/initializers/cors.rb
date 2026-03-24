# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Read more: https://github.com/cyu/rack-cors

# Space- or comma-separated extra origins in ENV["CORS_ORIGINS"].
# Production example (Railway + custom domain):
#   CORS_ORIGINS=https://www.expressfeel.com,https://expressfeel.com
# Without a matching origin, browsers block cross-origin XHR/fetch (CORS preflight fails).
default_origins = %w[
  http://localhost:5174
  http://127.0.0.1:5174
  http://localhost:5173
  http://127.0.0.1:5173
]
extra_origins = ENV["CORS_ORIGINS"].to_s.split(/[\s,]+/).map(&:strip).reject(&:blank?)
cors_origins = (default_origins + extra_origins).uniq

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*cors_origins)

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head]
  end
end
