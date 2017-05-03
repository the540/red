# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#
require 'faker'

[User, Node, ServiceTemplate].each do |m|
  m.delete_all
end

Faker::Config.locale

1.upto(200) do |i|
  Node.create hostname: "114.55.130.152", state: 'active'
end

Faker::Config.locale = :en
1.upto(200) do |i|
  ServiceTemplate.create name: Faker::Name.name,
    icon: Faker::Avatar.image("my-own-slug"),
    desc: Faker::Lorem.sentence(3),
    readme: (1.upto(30).map do  Faker::Markdown.random end).join
end


u = User.new email: "admin@admin.com", role: "SITE_ADMIN"
u.update_password "admin"
u.save

