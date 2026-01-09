namespace :admin do
  desc "Make a user admin by username"
  task :make, [ :username ] => :environment do |t, args|
    username = args[:username]
    if username.blank?
      puts "Usage: rails admin:make[username]"
      exit 1
    end

    user = User.find_by(username: username)
    if user.nil?
      puts "User '#{username}' not found"
      exit 1
    end

    if user.admin?
      puts "User '#{username}' is already an admin"
    else
      user.update!(role: "admin")
      puts "User '#{username}' is now an admin"
    end
  end

  desc "Make a user moderator by username"
  task :make_moderator, [ :username ] => :environment do |t, args|
    username = args[:username]
    if username.blank?
      puts "Usage: rails admin:make_moderator[username]"
      exit 1
    end

    user = User.find_by(username: username)
    if user.nil?
      puts "User '#{username}' not found"
      exit 1
    end

    if user.moderator? || user.admin?
      puts "User '#{username}' is already a #{user.role}"
    else
      user.update!(role: "moderator")
      puts "User '#{username}' is now a moderator"
    end
  end

  desc "Remove admin/moderator role from user"
  task :demote, [ :username ] => :environment do |t, args|
    username = args[:username]
    if username.blank?
      puts "Usage: rails admin:demote[username]"
      exit 1
    end

    user = User.find_by(username: username)
    if user.nil?
      puts "User '#{username}' not found"
      exit 1
    end

    if user.user?
      puts "User '#{username}' is already a regular user"
    else
      user.update!(role: "user")
      puts "User '#{username}' is now a regular user"
    end
  end

  desc "List all admins and moderators"
  task list: :environment do
    admins = User.where(role: "admin")
    moderators = User.where(role: "moderator")

    puts "Admins (#{admins.count}):"
    admins.each { |u| puts "  - #{u.username} (#{u.email})" }

    puts "\nModerators (#{moderators.count}):"
    moderators.each { |u| puts "  - #{u.username} (#{u.email})" }
  end
end
