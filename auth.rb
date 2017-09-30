#!/usr/bin/env ruby
# coding: UTF-8

require "sqlite3"
require "rotp"

AUTH_FAIL = 1
AUTH_SUCCESS = 0

if ARGV.size != 1 then
    exit(AUTH_FAIL)
end

username, password = "", ""
open(ARGV.first, "r") do |f|
    username = f.readline.chomp
    password = f.readline.chomp
end

unless password =~ /^\d{6}$/ then
    exit(AUTH_FAIL)
end

db = SQLite3::Database.new "/usr/local/etc/openvpn/users.db"

row = db.execute("select name, otp_secret from users where name = ?", [username])

if row.size != 1 then
    exit(AUTH_FAIL)
end

otp_secret = row.first[1]
totp = ROTP::TOTP.new(otp_secret)

result = totp.verify(password) ? AUTH_SUCCESS : AUTH_FAIL

if result == AUTH_SUCCESS then
    db.execute("update users set last_login = datetime('now', 'localtime') where name = ?", [username])
end

exit(result)
