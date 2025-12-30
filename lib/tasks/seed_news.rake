namespace :seed do
  desc "Add news articles from HackerNews, Slashdot and Crossweb events"
  task news: :environment do
    bot = User.find_or_create_by!(email: "bot@tabdevs.pl") do |u|
      u.username = "tabdevs-bot"
      u.role = :user
      u.karma = 0
    end

    posts_data = [
      # HackerNews
      {
        title: "Everything as Code: How We Manage Our Company in One Monorepo",
        url: "https://www.kasava.dev/blog/everything-as-code-monorepo",
        hours_ago: 2
      },
      {
        title: "FediMeteo: A 4 EUR FreeBSD VPS Became a Global Weather Service",
        url: "https://it-notes.dragas.net/2025/02/26/fedimeteo-how-a-tiny-freebsd-vps-became-a-global-weather-service-for-thousands/",
        hours_ago: 3
      },
      {
        title: "A faster heart for F-Droid - nowy serwer",
        url: "https://f-droid.org/2025/12/30/a-faster-heart-for-f-droid.html",
        hours_ago: 4
      },
      {
        title: "Toro: Deploy Applications as Unikernels",
        url: "https://github.com/torokernel/torokernel",
        hours_ago: 5
      },
      {
        title: "A Vulnerability in Libsodium",
        url: "https://00f.net/2025/12/30/libsodium-vulnerability/",
        hours_ago: 6
      },
      {
        title: "22 GB of Hacker News in SQLite",
        url: "https://hackerbook.dosaygo.com",
        hours_ago: 8
      },
      {
        title: "Meta kupilo Manus - startup AI o ktorym wszyscy mowia",
        url: "https://techcrunch.com/2025/12/29/meta-just-bought-manus-an-ai-startup-everyone-has-been-talking-about/",
        hours_ago: 10
      },
      {
        title: "Loss32: Let's Build a Win32/Linux",
        url: "https://loss32.org/",
        hours_ago: 12
      },
      {
        title: "Reverse Engineering a Mysterious UDP Stream in My Hotel",
        url: "https://www.gkbrk.com/hotel-music",
        hours_ago: 14
      },
      {
        title: "Software Developers Don't Vibe, They Control: AI Agent Coding in 2025",
        url: "https://arxiv.org/abs/2512.14012",
        hours_ago: 16
      },
      # Crossweb events
      {
        title: "WarsawJS Meetup #134 - onsite",
        url: "https://crossweb.pl/wydarzenia/warsawjs-meetup-134-onsite/",
        body: "Kolejna edycja WarsawJS w Warszawie. 14 stycznia 2026. Spotkanie dla programistow JavaScript/TypeScript.",
        hours_ago: 1
      },
      {
        title: "WordUp Krakow - styczen 2026",
        url: "https://crossweb.pl/wydarzenia/wordup-krakow-styczen-2026/",
        body: "Spotkanie spolecznosci WordPress w Krakowie. 12 stycznia 2026.",
        hours_ago: 7
      },
      {
        title: "Nighthack - hackathon w Krakowie",
        url: "https://crossweb.pl/wydarzenia/nighthack-wpadnij-razem-z-nami-ciac-lutowac-i-kodowac-styczen-2026/",
        body: "Wpadnij razem z nami ciac, lutowac i kodowac! 9 stycznia 2026 w Krakowie.",
        hours_ago: 9
      },
      {
        title: "Bitcoin Cafe Warszawa [EN/PL]",
        url: "https://crossweb.pl/wydarzenia/bitcoin-caf-enpl-styczen-2026/",
        body: "Spotkanie dla entuzjastow kryptowalut i technologii blockchain. 5 stycznia 2026, Warszawa.",
        hours_ago: 11
      },
      {
        title: "UGotIT 2025 - Konkurs technologiczny",
        url: "https://crossweb.pl/wydarzenia/u-got-it-2025/",
        body: "Konkurs technologiczny dla studentow i mlodych programistow. Wydarzenie online.",
        hours_ago: 18
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
