# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200411183221) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "invites", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "token"
    t.string   "email"
    t.integer  "list_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "listings", force: :cascade do |t|
    t.integer  "list_id"
    t.integer  "movie_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.integer  "priority"
  end

  add_index "listings", ["list_id"], name: "index_listings_on_list_id", using: :btree
  add_index "listings", ["movie_id"], name: "index_listings_on_movie_id", using: :btree

  create_table "lists", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "is_main",     default: false, null: false
    t.boolean  "is_public",   default: false, null: false
    t.string   "slug"
    t.text     "description"
  end

  add_index "lists", ["slug"], name: "index_lists_on_slug", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "list_id"
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "memberships", ["list_id"], name: "index_memberships_on_list_id", using: :btree

  create_table "movies", force: :cascade do |t|
    t.string   "title"
    t.integer  "tmdb_id"
    t.string   "imdb_id"
    t.string   "backdrop_path"
    t.string   "poster_path"
    t.date     "release_date"
    t.text     "overview"
    t.string   "trailer"
    t.float    "vote_average"
    t.float    "popularity"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "genres",        default: [],                 array: true
    t.string   "actors",        default: [],                 array: true
    t.boolean  "adult",         default: false, null: false
    t.integer  "runtime"
    t.string   "slug"
    t.string   "director"
    t.integer  "director_id"
    t.string   "mpaa_rating"
  end

  add_index "movies", ["slug"], name: "index_movies_on_slug", unique: true, using: :btree
  add_index "movies", ["tmdb_id"], name: "index_movies_on_tmdb_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "movie_id"
    t.integer  "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ratings", ["movie_id"], name: "index_ratings_on_movie_id", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "movie_id"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "reviews", ["movie_id"], name: "index_reviews_on_movie_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "screenings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "movie_id"
    t.date     "date_watched"
    t.string   "location_watched"
    t.text     "notes"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "screenings", ["movie_id"], name: "index_screenings_on_movie_id", using: :btree
  add_index "screenings", ["user_id"], name: "index_screenings_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "movie_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "taggings", ["movie_id"], name: "index_taggings_on_movie_id", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["user_id"], name: "index_taggings_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "username"
    t.string   "slug"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "default_location"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

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
end
