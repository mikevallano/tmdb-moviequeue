# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
  key: '_tmdb-moviequeue_session',
  expire_after: 2.weeks,
  secure: Rails.env.production?,
  same_site: :lax
