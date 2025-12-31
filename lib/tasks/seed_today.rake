namespace :seed do
  desc "Add today's news articles from HackerNews and Crossweb events"
  task today: :environment do
    bot = User.find_or_create_by!(email: "bot@tabdevs.pl") do |u|
      u.username = "tabdevs-bot"
      u.role = :user
      u.karma = 0
    end

    posts_data = [
      # HackerNews - today's top stories
      {
        title: "Show HN: Use Claude Code to Query 600 GB Indexes over Hacker News, ArXiv",
        url: "https://exopriors.com/scry",
        hours_ago: 1
      },
      {
        title: "The Rise of Industrial Software",
        url: "https://chrisloy.dev/post/2025/12/30/the-rise-of-industrial-software",
        hours_ago: 2
      },
      {
        title: "Tixl: Open-source Realtime Motion Graphics",
        url: "https://github.com/tixl3d/tixl",
        hours_ago: 3
      },
      {
        title: "Animated AI - wizualizacje sieci neuronowych",
        url: "https://animatedai.github.io/",
        hours_ago: 4
      },
      {
        title: "Doom in Django: Testing the Limits of LiveView at 600k divs/segundo",
        url: "https://en.andros.dev/blog/7b1b607b/doom-in-django-testing-the-limits-of-liveview-at-600000-divssegundo/",
        hours_ago: 5
      },
      {
        title: "Readings in Database Systems (5th Edition) - Red Book",
        url: "http://www.redbook.io/",
        hours_ago: 6
      },
      {
        title: "Odin: Moving Towards a New core:OS",
        url: "https://odin-lang.org/news/moving-towards-a-new-core-os/",
        hours_ago: 7
      },
      {
        title: "Honey's Dieselgate: Detecting and Tricking Testers",
        url: "https://vptdigital.com/blog/honey-detecting-testers/",
        hours_ago: 8
      },
      {
        title: "Akin's Laws of Spacecraft Design [PDF]",
        url: "https://www.ece.uvic.ca/~elec399/201409/Akin%27s%20Laws%20of%20Spacecraft%20Design.pdf",
        hours_ago: 10
      },
      {
        title: "Three Norths Alignment About to End",
        url: "https://www.spatialsource.com.au/three-norths-alignment-about-to-end/",
        hours_ago: 12
      },
      # Crossweb events - Polish tech meetups
      {
        title: "OpenCoffeeKRK #304 - networking dla startupow",
        url: "https://crossweb.pl/wydarzenia/opencoffeekrk-304/",
        body: "Nieformalne spotkanie networkingowe dla startupow i przedsiebiorcow. 8 stycznia 2026, Krakow.",
        hours_ago: 1
      },
      {
        title: "SysOps/DevOps Wroclaw MeetUp #25",
        url: "https://crossweb.pl/wydarzenia/sysops-devops-wroclaw-meetup-25/",
        body: "Spotkanie spolecznosci DevOps we Wroclawiu. Tematy: Kubernetes, CI/CD, infrastruktura. 14 stycznia 2026.",
        hours_ago: 3
      },
      {
        title: "GoCracow #17 - Error Codes, TSDB in Go, PGO",
        url: "https://crossweb.pl/wydarzenia/gocracow-17-designing-error-codes-tsdb-in-go-pgo/",
        body: "Meetup dla programistow Go w Krakowie. Tematy: projektowanie kodow bledow, bazy czasowe, optymalizacja. 19 stycznia 2026.",
        hours_ago: 5
      },
      {
        title: "HackJam | Global GameJam Gdansk 2026",
        url: "https://crossweb.pl/wydarzenia/hackjam-global-gamejam-gdansk-2026/",
        body: "48-godzinny hackathon tworzenia gier. Dolacz do globalnej spolecznosci game devow! 30-31 stycznia 2026, Gdansk.",
        hours_ago: 8
      },
      {
        title: "SQLDay 2026 - konferencja bazodanowa",
        url: "https://crossweb.pl/wydarzenia/sqlday-2026/",
        body: "Najwieksza konferencja SQL i baz danych w Polsce. 11-13 maja 2026, Wroclaw + online.",
        hours_ago: 14
      }
    ]

    created = 0
    posts_data.each do |data|
      next if Post.exists?(url: data[:url])

      post = Post.create!(
        title: data[:title],
        url: data[:url],
        body: data[:body],
        author: bot,
        post_type: :link,
        score: rand(5..25),
        created_at: data[:hours_ago].hours.ago
      )
      post.upvote!(bot)
      created += 1
      puts "Created: #{data[:title]}"
    end

    puts "Done! Created #{created} posts."
  end
end
