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

ActiveRecord::Schema[8.1].define(version: 2026_03_19_150752) do
  create_table "entries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body", null: false, collation: "utf8mb4_0900_bin"
    t.text "body_html", collation: "utf8mb4_0900_bin"
    t.datetime "created_at", null: false
    t.date "posted_on", null: false
    t.integer "tag", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "posted_on"], name: "index_entries_on_user_id_and_posted_on"
    t.index ["user_id", "tag", "posted_on"], name: "index_entries_on_user_id_and_tag_and_posted_on"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "passkey_credentials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", null: false, collation: "utf8mb4_0900_bin"
    t.datetime "last_used_at"
    t.string "nickname", collation: "utf8mb4_0900_bin"
    t.text "public_key", null: false, collation: "utf8mb4_0900_bin"
    t.integer "sign_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["external_id"], name: "index_passkey_credentials_on_external_id", unique: true
    t.index ["user_id"], name: "index_passkey_credentials_on_user_id"
  end

  create_table "taggings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.bigint "taggable_id", null: false
    t.string "taggable_type", null: false, collation: "utf8mb4_0900_bin"
    t.datetime "updated_at", null: false
    t.index ["tag_id", "taggable_type", "taggable_id"], name: "index_taggings_on_tag_id_and_taggable_type_and_taggable_id", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
  end

  create_table "tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false, collation: "utf8mb4_0900_bin"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "todo_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "completed", default: false, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.date "due_date", null: false
    t.date "original_due_date", null: false
    t.integer "position", default: 0, null: false
    t.string "title", null: false, collation: "utf8mb4_0900_bin"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "completed", "due_date"], name: "index_todo_items_on_user_id_and_completed_and_due_date"
    t.index ["user_id", "due_date", "completed"], name: "index_todo_items_on_user_id_and_due_date_and_completed"
    t.index ["user_id"], name: "index_todo_items_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "api_token", collation: "utf8mb4_0900_bin"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip", collation: "utf8mb4_0900_bin"
    t.string "email", null: false, collation: "utf8mb4_0900_bin"
    t.string "encrypted_password", null: false, collation: "utf8mb4_0900_bin"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip", collation: "utf8mb4_0900_bin"
    t.datetime "locked_at"
    t.boolean "passkey_setup_prompted", default: false, null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token", collation: "utf8mb4_0900_bin"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unlock_token", collation: "utf8mb4_0900_bin"
    t.datetime "updated_at", null: false
    t.string "username", null: false, collation: "utf8mb4_0900_bin"
    t.string "webauthn_id", default: -> { "(uuid())" }, null: false, collation: "utf8mb4_0900_bin"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
    t.index ["webauthn_id"], name: "index_users_on_webauthn_id", unique: true
  end

  add_foreign_key "entries", "users"
  add_foreign_key "passkey_credentials", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "todo_items", "users"
end
