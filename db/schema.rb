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

ActiveRecord::Schema[8.1].define(version: 2025_12_30_144707) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bans", force: :cascade do |t|
    t.integer "ban_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.bigint "moderator_id", null: false
    t.text "reason", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["moderator_id"], name: "index_bans_on_moderator_id"
    t.index ["user_id", "expires_at"], name: "index_bans_on_user_id_and_expires_at"
    t.index ["user_id"], name: "index_bans_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "edited_at"
    t.bigint "parent_id"
    t.bigint "post_id", null: false
    t.integer "score", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["author_id", "created_at"], name: "index_comments_on_author_id_and_created_at"
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["post_id", "parent_id"], name: "index_comments_on_post_id_and_parent_id"
    t.index ["post_id", "status", "parent_id"], name: "index_comments_on_post_id_and_status_and_parent_id"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["status"], name: "index_comments_on_status"
  end

  create_table "magic_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.bigint "user_id", null: false
    t.index ["token"], name: "index_magic_links_on_token", unique: true
    t.index ["user_id", "expires_at"], name: "index_magic_links_on_user_id_and_expires_at"
    t.index ["user_id"], name: "index_magic_links_on_user_id"
  end

  create_table "moderation_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "moderatable_id", null: false
    t.string "moderatable_type", null: false
    t.bigint "moderator_id"
    t.integer "reason", default: 0, null: false
    t.datetime "resolved_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["moderatable_type", "moderatable_id"], name: "index_moderation_items_on_moderatable"
    t.index ["moderator_id"], name: "index_moderation_items_on_moderator_id"
    t.index ["status"], name: "index_moderation_items_on_status"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "actor_id"
    t.datetime "created_at", null: false
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.integer "notification_type", default: 0, null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.text "body"
    t.integer "comments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "edited_at"
    t.string "normalized_url"
    t.integer "post_type", default: 0, null: false
    t.integer "score", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "tag"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["author_id", "created_at"], name: "index_posts_on_author_id_and_created_at"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["normalized_url"], name: "index_posts_on_normalized_url"
    t.index ["status", "created_at"], name: "index_posts_on_status_and_created_at"
    t.index ["url"], name: "index_posts_on_url"
  end

  create_table "site_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["key"], name: "index_site_settings_on_key", unique: true
  end

  create_table "sources", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "last_fetched_at"
    t.string "name", null: false
    t.integer "source_type", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "karma", default: 0, null: false
    t.string "password_digest"
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "value", null: false
    t.bigint "votable_id", null: false
    t.string "votable_type", null: false
    t.index ["user_id", "votable_type", "votable_id"], name: "index_votes_on_user_id_and_votable_type_and_votable_id", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable"
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable_type_and_votable_id"
  end

  add_foreign_key "bans", "users"
  add_foreign_key "bans", "users", column: "moderator_id"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users", column: "author_id"
  add_foreign_key "magic_links", "users"
  add_foreign_key "moderation_items", "users", column: "moderator_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "votes", "users"
end
