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

ActiveRecord::Schema.define(version: 20150603110612) do

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "zendesk_id"
    t.boolean  "zbox_mail",   default: false
    t.boolean  "dte_default", default: false
    t.boolean  "admin",       default: false
  end

  add_index "accounts", ["zendesk_id"], name: "index_accounts_on_zendesk_id"

  create_table "domains", force: :cascade do |t|
    t.string   "name"
    t.integer  "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "domains", ["account_id"], name: "index_domains_on_account_id"

  create_table "dte_messages", force: :cascade do |t|
    t.string   "to"
    t.string   "from"
    t.text     "message_id"
    t.string   "cc"
    t.datetime "sent_date"
    t.string   "return_qid"
    t.integer  "account_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "qid"
    t.string   "rut_emisor"
    t.string   "rut_receptor"
  end

  add_index "dte_messages", ["account_id"], name: "index_dte_messages_on_account_id"
  add_index "dte_messages", ["from"], name: "index_dte_messages_on_from"
  add_index "dte_messages", ["rut_emisor"], name: "index_dte_messages_on_rut_emisor"
  add_index "dte_messages", ["rut_receptor"], name: "index_dte_messages_on_rut_receptor"
  add_index "dte_messages", ["to"], name: "index_dte_messages_on_to"

  create_table "dtes", force: :cascade do |t|
    t.integer  "folio"
    t.string   "rut_receptor"
    t.string   "rut_emisor"
    t.string   "msg_type"
    t.string   "setdte_id"
    t.integer  "dte_type"
    t.date     "fecha_emision"
    t.date     "fecha_recepcion"
    t.integer  "dte_message_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "dtes", ["dte_type"], name: "index_dtes_on_dte_type"
  add_index "dtes", ["rut_emisor"], name: "index_dtes_on_rut_emisor"
  add_index "dtes", ["rut_receptor"], name: "index_dtes_on_rut_receptor"

  create_table "mta_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "search_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "servers", force: :cascade do |t|
    t.string   "name"
    t.integer  "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "servers", ["account_id"], name: "index_servers_on_account_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "account_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "role"
    t.string   "description"
    t.string   "image"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "zendesk_account_id"
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
