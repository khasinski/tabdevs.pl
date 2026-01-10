namespace :karma do
  desc "Recalculate karma for all users"
  task recalculate_all: :environment do
    puts "Recalculating karma for all users..."
    User.find_each do |user|
      old_karma = user.karma
      user.recalculate_karma!
      if old_karma != user.karma
        puts "#{user.username}: #{old_karma} -> #{user.karma}"
      end
    end
    puts "Done!"
  end
end
