namespace :seed do
  desc "Add articles from diverse Polish tech sources"
  task polish: :environment do
    bot = User.find_or_create_by!(email: "bot@tabdevs.pl") do |u|
      u.username = "tabdevs-bot"
      u.role = :user
      u.karma = 0
    end

    posts_data = [
      # Antyweb
      {
        title: "Polska cyfryzacja 2026: co nas czeka w nowym roku?",
        url: "https://antyweb.pl/polska-cyfryzacja-2026",
        hours_ago: 2
      },
      {
        title: "Windows 11 26H1 - wszystko co wiemy o nadchodzącej aktualizacji",
        url: "https://antyweb.pl/windows-11-26h1-nadchodzaca-aktualizacja",
        hours_ago: 8
      },
      {
        title: "Samsung prezentuje nowości na CES 2026",
        url: "https://antyweb.pl/samsung-ces-2026-nowosci",
        hours_ago: 14
      },

      # Spider's Web
      {
        title: "Netflix, Disney+, HBO - co warto obejrzeć w styczniu 2026",
        url: "https://spidersweb.pl/rozrywka/netflix-disney-hbo-styczen-2026",
        hours_ago: 3
      },
      {
        title: "Misje kosmiczne 2026 - kalendarz NASA i ESA",
        url: "https://spidersweb.pl/nauka/misje-kosmiczne-2026-nasa-esa",
        hours_ago: 12
      },
      {
        title: "Składany iPhone - wszystko co wiemy o planach Apple",
        url: "https://spidersweb.pl/2026/01/skladany-iphone-apple-plotki",
        hours_ago: 20
      },

      # Zaufana Trzecia Strona (ZTS)
      {
        title: "Weekendowa Lektura #657 - przegląd bezpieczeństwa",
        url: "https://zaufanatrzeciastrona.pl/post/weekendowa-lektura-657/",
        hours_ago: 1
      },
      {
        title: "Analiza: jak działał SantaStealer - świąteczny malware",
        url: "https://zaufanatrzeciastrona.pl/post/analiza-santastealer-malware/",
        hours_ago: 16
      },
      {
        title: "Kod źródłowy mObywatel opublikowany - przegląd bezpieczeństwa",
        url: "https://zaufanatrzeciastrona.pl/post/mobywatel-kod-zrodlowy-analiza/",
        hours_ago: 24
      },

      # ITwiz
      {
        title: "Polskie firmy IT w 2026 - trendy i prognozy",
        url: "https://itwiz.pl/polskie-firmy-it-2026-trendy-prognozy/",
        hours_ago: 5
      },
      {
        title: "Cloud w Polsce: AWS, Azure czy GCP - co wybierają przedsiębiorstwa",
        url: "https://itwiz.pl/cloud-polska-aws-azure-gcp-2026/",
        hours_ago: 18
      },

      # 4programmers.net
      {
        title: "Rust vs Go w 2026 - który język wybrać do nowego projektu?",
        url: "https://4programmers.net/Forum/Pair_programming/rust-vs-go-2026",
        body: "Dyskusja społeczności o wyborze między Rust a Go do nowych projektów.",
        hours_ago: 4
      },
      {
        title: "Junior Developer w Polsce - jak wygląda rynek pracy w 2026?",
        url: "https://4programmers.net/Forum/Pair_programming/junior-developer-rynek-2026",
        body: "Wątek o sytuacji juniorów na rynku IT w Polsce.",
        hours_ago: 22
      },

      # Crossweb events
      {
        title: "Azure User Group Poland - spotkanie online",
        url: "https://crossweb.pl/wydarzenia/azure-user-group-poland-styczen-2026/",
        body: "Spotkanie społeczności Azure w Polsce. 15 stycznia 2026, online.",
        hours_ago: 6
      },
      {
        title: "meet.js Poznań #67",
        url: "https://crossweb.pl/wydarzenia/meet-js-poznan-67/",
        body: "Kolejne spotkanie meet.js w Poznaniu. 16 stycznia 2026.",
        hours_ago: 10
      },
      {
        title: "ISSA Polska - cyberbezpieczeństwo w praktyce",
        url: "https://crossweb.pl/wydarzenia/issa-polska-cyberbezpieczenstwo-styczen-2026/",
        body: "Warsztat o praktycznym podejściu do bezpieczeństwa IT. Warszawa, 18 stycznia 2026.",
        hours_ago: 15
      },
      {
        title: "SQLDay 2026 - konferencja SQL w Polsce",
        url: "https://sqlday.pl/2026/",
        body: "Największa konferencja SQL Server i Azure SQL w Polsce. Wrocław, marzec 2026.",
        hours_ago: 28
      },

      # Computerworld Polska
      {
        title: "AI Act wchodzi w życie - co to oznacza dla polskich firm",
        url: "https://www.computerworld.pl/news/ai-act-polska-firmy-2026.html",
        hours_ago: 7
      },
      {
        title: "Cyberataki na polską infrastrukturę - raport za 2025",
        url: "https://www.computerworld.pl/news/cyberataki-polska-raport-2025.html",
        hours_ago: 26
      },

      # Just Join IT (blog)
      {
        title: "Zarobki w IT 2026 - raport płacowy",
        url: "https://blog.justjoin.it/zarobki-it-2026-raport/",
        body: "Najnowszy raport o wynagrodzeniach w branży IT w Polsce.",
        hours_ago: 9
      },
      {
        title: "Remote work w polskim IT - jak firmy adaptują się w 2026",
        url: "https://blog.justjoin.it/remote-work-polska-it-2026/",
        hours_ago: 30
      },

      # Bulldogjob
      {
        title: "Najpopularniejsze frameworki JavaScript w Polsce - badanie 2026",
        url: "https://bulldogjob.pl/readme/najpopularniejsze-frameworki-javascript-2026",
        hours_ago: 11
      },

      # Programista Magazine
      {
        title: "Domain-Driven Design w praktyce - case study polskiej firmy",
        url: "https://programistamag.pl/ddd-praktyka-case-study/",
        hours_ago: 32
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

    puts "Done! Created #{created} posts from Polish sources."
  end
end
