namespace :news do
  desc "Add sample news posts"
  task add_samples: :environment do
    bot = User.find_or_create_by!(email: "bot@tabdevs.pl") do |u|
      u.username = "tabdevs"
      u.role = :bot
    end

    news_items = [
      {
        title: "Rails 8.1 oficjalnie wydany - co nowego?",
        url: "https://rubyonrails.org/2024/12/rails-8-1-released",
        body: "Rails 8.1 wprowadza wiele usprawnień w SolidQueue, SolidCache i SolidCable. Nowa wersja zawiera też lepszą integrację z Hotwire."
      },
      {
        title: "GitHub Copilot teraz dostępny za darmo dla wszystkich",
        url: "https://github.blog/news-insights/product-news/github-copilot-in-vscode-free/",
        body: "Microsoft ogłosił darmowy tier GitHub Copilot dla wszystkich deweloperów z limitem 2000 uzupełnień kodu miesięcznie."
      },
      {
        title: "PostgreSQL 17 - przegląd najważniejszych zmian",
        url: "https://www.postgresql.org/about/news/postgresql-17-released-2936/",
        body: "Nowa wersja PostgreSQL przynosi znaczące usprawnienia w wydajności zapytań JSON oraz lepsze wsparcie dla partycjonowania."
      },
      {
        title: "Tailwind CSS 4.0 w fazie beta",
        url: "https://tailwindcss.com/blog/tailwindcss-v4-beta",
        body: "Tailwind 4.0 wprowadza nowy silnik oparty na Rust, znacznie przyspieszając kompilację stylów."
      },
      {
        title: "Ruby 3.4 - YJIT jeszcze szybszy",
        url: "https://www.ruby-lang.org/en/news/2024/12/25/ruby-3-4-0-released/",
        body: "Ruby 3.4 kontynuuje rozwój YJIT z kolejnymi optymalizacjami. Benchmarki pokazują nawet 20% przyrost wydajności."
      }
    ]

    news_items.each do |item|
      post = Post.find_or_initialize_by(url: item[:url])
      if post.new_record?
        post.assign_attributes(
          title: item[:title],
          body: item[:body],
          author: bot,
          score: 0,
          status: :active
        )
        post.save!
        puts "Created: #{item[:title]}"
      else
        puts "Already exists: #{item[:title]}"
      end
    end

    puts "Done! Added news posts with score: 0"
  end
end
