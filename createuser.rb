#!/usr/bin/env ruby
# coding: UTF-8

require "sqlite3"
require "rotp"
require 'uri'

while true do
    print "username: "
    username = gets
    if username then
        username.chomp!
        if (!username.empty? && username =~ /^[a-zA-Z0-9_\-@.]{1,30}$/) then
            break
        else
            puts "invalid username."
        end
    else
        exit()
    end
end

opt_secret = ROTP::Base32.random_base32
top = ROTP::TOTP.new(opt_secret)
url = top.provisioning_uri(username)
qrcode_url = "https://www.google.com/chart?chs=200x200&cht=qr&chl=#{URI.escape(url)}"

db = SQLite3::Database.new "/usr/local/etc/openvpn/users.db"

rows = db.execute <<-DDL
create table if not exists users (
    name text primary key,
    otp_secret text not null,
    last_login numeric
);  
DDL

row = db.execute("select count(*) from users where name = ?", [username])
if row.first[0] == 0
    db.execute("insert into users (name, otp_secret) values (?, ?)",
      [username, opt_secret])

    puts "create new user."
    puts "OTP QR Code: "
    puts qrcode_url
else
    puts "user is already exists."
end
