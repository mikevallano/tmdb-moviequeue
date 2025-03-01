# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_01_133624) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "invites", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "receiver_id"
    t.string "token"
    t.string "email"
    t.integer "list_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "listings", force: :cascade do |t|
    t.integer "list_id"
    t.integer "movie_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.integer "priority"
    t.index ["list_id"], name: "index_listings_on_list_id"
    t.index ["movie_id", "list_id"], name: "index_listings_on_movie_id_and_list_id", unique: true
    t.index ["movie_id"], name: "index_listings_on_movie_id"
  end

  create_table "lists", force: :cascade do |t|
    t.integer "owner_id"
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "is_main", default: false, null: false
    t.boolean "is_public", default: false, null: false
    t.string "slug"
    t.text "description"
    t.index ["slug"], name: "index_lists_on_slug"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "list_id"
    t.integer "member_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["list_id"], name: "index_memberships_on_list_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.integer "tmdb_id"
    t.string "imdb_id"
    t.string "backdrop_path"
    t.string "poster_path"
    t.date "release_date"
    t.text "overview"
    t.string "trailer"
    t.float "vote_average"
    t.float "popularity"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "genres", default: [], array: true
    t.string "actors", default: [], array: true
    t.boolean "adult", default: false, null: false
    t.integer "runtime"
    t.string "slug"
    t.string "director"
    t.integer "director_id"
    t.string "mpaa_rating"
    t.index ["slug"], name: "index_movies_on_slug", unique: true
    t.index ["tmdb_id"], name: "index_movies_on_tmdb_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "movie_id"
    t.integer "value"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["movie_id"], name: "index_ratings_on_movie_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id"
    t.integer "movie_id"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["movie_id"], name: "index_reviews_on_movie_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "screenings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "movie_id"
    t.date "date_watched"
    t.string "location_watched"
    t.text "notes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["movie_id"], name: "index_screenings_on_movie_id"
    t.index ["user_id"], name: "index_screenings_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "movie_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["movie_id"], name: "index_taggings_on_movie_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["user_id"], name: "index_taggings_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tv_series_viewings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.string "url", null: false
    t.string "show_id", null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ended_at"], name: "index_tv_series_viewings_on_ended_at"
    t.index ["show_id"], name: "index_tv_series_viewings_on_show_id"
    t.index ["user_id"], name: "index_tv_series_viewings_on_user_id"
  end

  create_table "user_streaming_service_providers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.uuid "streaming_service_provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_streaming_service_providers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "username"
    t.string "slug"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "default_location"
    t.boolean "admin", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "listings", "lists"
  add_foreign_key "listings", "movies"
  add_foreign_key "memberships", "lists"
  add_foreign_key "ratings", "movies"
  add_foreign_key "ratings", "users"
  add_foreign_key "reviews", "movies"
  add_foreign_key "reviews", "users"
  add_foreign_key "screenings", "movies"
  add_foreign_key "screenings", "users"
  add_foreign_key "taggings", "movies"
  add_foreign_key "taggings", "tags"
  add_foreign_key "taggings", "users"
  add_foreign_key "tv_series_viewings", "users"
  add_foreign_key "user_streaming_service_providers", "users"
end
