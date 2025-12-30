# Create admin user
admin = User.find_or_create_by!(email: "admin@tabdevs.pl") do |u|
  u.username = "admin"
  u.role = :admin
  u.karma = 100
end

# Create bot user (bot? is determined by username == "tabdevs-bot")
bot = User.find_or_create_by!(email: "bot@tabdevs.pl") do |u|
  u.username = "tabdevs-bot"
  u.role = :user
  u.karma = 0
end

# Create some regular users
users = []
5.times do |i|
  users << User.find_or_create_by!(email: "user#{i + 1}@example.com") do |u|
    u.username = "dev#{i + 1}"
    u.karma = rand(10..50)
  end
end

puts "Created #{User.count} users"

# Create posts
posts_data = [
  { title: "Rails 8 - Najwazniejsze zmiany i nowosci", url: "https://rubyonrails.org/2024/11/7/rails-8-no-paas-required", author: users[0] },
  { title: "Jak zoptymalizowac zapytania SQL w PostgreSQL", url: "https://www.postgresql.org/docs/current/performance-tips.html", author: users[1] },
  { title: "TypeScript 5.7 - nowe funkcje", url: "https://devblogs.microsoft.com/typescript/announcing-typescript-5-7/", author: users[2] },
  { title: "Ask: Jakie IDE polecacie do Ruby?", body: "Szukam dobrego IDE do pracy z Ruby/Rails. Uzywalem VSCode, ale szukam czegos lepszego. Co polecacie?", tag: :ask, author: users[3] },
  { title: "Show: Moj side project - generator faktur w Rails", url: "https://github.com/example/invoice-generator", tag: :show, author: users[4] },
  { title: "Docker vs Podman - porownanie dla developerow", url: "https://podman.io/blogs/2024/", author: users[0] },
  { title: "Nowy ChatGPT o1 - co oznacza dla developerow?", url: "https://openai.com/index/introducing-o1-preview/", author: bot, tag: :news },
  { title: "Jak zaczac z Hotwire/Turbo w Rails", url: "https://turbo.hotwired.dev/handbook/introduction", author: users[1] },
  { title: "Case study: Migracja z monolitu do mikroserwisow", body: "Przez ostatni rok migrowalismy nasz monolit Rails do architektury mikroserwisowej. Oto nasze doswiadczenia, bledy i wnioski...", tag: :case_study, author: users[2] },
  { title: "Rust dla programistow Ruby - wprowadzenie", url: "https://www.rust-lang.org/learn", author: users[3] },
  { title: "GitHub Copilot - czy warto?", body: "Uzywam Copilota od pol roku. Oto moje przemyslenia i czy warto placic 10$ miesiecznie.", author: users[4] },
  { title: "Nowa wersja Ruby 3.4 - pattern matching i YJIT", url: "https://www.ruby-lang.org/en/news/", author: bot, tag: :news },
  { title: "Jak pisac czyste testy w RSpec", url: "https://rspec.info/features/", author: users[0] },
  { title: "Wprowadzenie do WebAssembly dla backend developerow", url: "https://webassembly.org/", author: users[1] },
  { title: "Ask: Jak radziicie sobie z burnoutem?", body: "Pracuje jako dev od 5 lat i czuje sie wypalony. Jak radzicie sobie z tym problemem?", tag: :ask, author: users[2] },
  { title: "Kubernetes dla poczatkujacych - praktyczny przewodnik", url: "https://kubernetes.io/docs/tutorials/", author: users[3] },
  { title: "Show: CLI tool do zarzadzania .env plikami", url: "https://github.com/example/env-manager", tag: :show, author: users[4] },
  { title: "PostgreSQL 17 - co nowego?", url: "https://www.postgresql.org/about/news/postgresql-17-released-2936/", author: bot, tag: :news },
  { title: "Solidne podstawy architektury hexagonalnej", url: "https://alistair.cockburn.us/hexagonal-architecture/", author: users[0] },
  { title: "Dlaczego warto uczyc sie funkcyjnego programowania", body: "Nawet jesli nie uzywasz jezykow funkcyjnych na co dzien, zrozumienie paradygmatu funkcyjnego moze znacznie poprawic jakosci twojego kodu...", author: users[1] }
]

posts_data.each_with_index do |data, i|
  post = Post.find_or_create_by!(title: data[:title]) do |p|
    p.url = data[:url]
    p.body = data[:body]
    p.tag = data[:tag]
    p.author = data[:author]
    p.post_type = data[:url].present? ? :link : :text
    p.score = rand(1..50)
    p.created_at = rand(1..72).hours.ago
  end

  # Add some votes
  rand(1..5).times do
    voter = users.sample
    post.upvote!(voter) unless voter.voted_for?(post)
  end
end

puts "Created #{Post.count} posts"

# Add some comments
Post.all.each do |post|
  rand(0..5).times do
    commenter = users.sample
    comment = post.comments.create!(
      body: [
        "Swietny artykul, dzieki za udostepnienie!",
        "Ciekawe podejscie, ale mam pewne watpliwosci...",
        "Uzywalem tego i dziala swietnie w produkcji.",
        "Czy ktos ma doswiadczenie z tym w wiekszej skali?",
        "Dzieki za case study, bardzo pomocne!",
        "Mam podobne doswiadczenia, polecam tez sprawdzic...",
        "Nie zgadzam sie z tym podejsciem, lepsze jest...",
        "+1, uzywam tego od roku"
      ].sample,
      author: commenter,
      created_at: rand(1..48).hours.ago
    )
    comment.upvote!(commenter)

    # Sometimes add replies
    if rand < 0.3
      reply = post.comments.create!(
        body: [
          "Zgadzam sie!",
          "Dobry punkt.",
          "Dzieki za odpowiedz.",
          "Sprawdze to.",
          "Masz racje."
        ].sample,
        author: users.sample,
        parent: comment,
        created_at: comment.created_at + rand(1..12).hours
      )
      reply.upvote!(reply.author)
    end
  end
end

puts "Created #{Comment.count} comments"

# Create default site settings
SiteSetting.find_or_create_by!(key: "downvote_threshold") { |s| s.value = "0" }
SiteSetting.find_or_create_by!(key: "new_user_post_limit") { |s| s.value = "2" }
SiteSetting.find_or_create_by!(key: "posts_per_day_limit") { |s| s.value = "5" }

puts "Created site settings"
puts "Done! You can log in with any email to receive a magic link."
