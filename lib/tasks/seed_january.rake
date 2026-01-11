namespace :seed do
  desc "Add January 2026 articles and comments"
  task january: :environment do
    bot = User.find_or_create_by!(email: "bot@tabdevs.pl") do |u|
      u.username = "tabdevs-bot"
      u.role = :user
      u.karma = 0
    end

    # New articles
    posts_data = [
      # Technologie
      {
        title: "htmx 2.0 - czy to koniec ery SPA?",
        url: "https://htmx.org/posts/htmx-2-0/",
        hours_ago: 1
      },
      {
        title: "Bun 2.0 wydany - Node.js ma poważną konkurencję",
        url: "https://bun.sh/blog/bun-v2",
        hours_ago: 3
      },
      {
        title: "PostgreSQL 18 - zapowiedź funkcji i roadmapa",
        url: "https://www.postgresql.org/about/news/postgresql-18-roadmap/",
        hours_ago: 5
      },
      {
        title: "Dlaczego mass layoffs w tech nie mają sensu - analiza danych",
        url: "https://newsletter.pragmaticengineer.com/p/layoffs-analysis-2026",
        hours_ago: 7
      },
      {
        title: "Typescript 5.8 - satisfies operator na sterydach",
        url: "https://devblogs.microsoft.com/typescript/announcing-typescript-5-8/",
        hours_ago: 9
      },

      # AI/ML
      {
        title: "Claude 4 vs GPT-5 - porównanie w praktyce programistycznej",
        url: "https://www.builder.io/blog/claude-4-vs-gpt-5-coding",
        hours_ago: 2
      },
      {
        title: "Ollama + open source LLM - jak postawić lokalny AI za darmo",
        url: "https://ollama.ai/blog/running-local-llms",
        hours_ago: 11
      },
      {
        title: "Cursor vs GitHub Copilot - który AI editor wybrać w 2026?",
        url: "https://blog.pragmaticengineer.com/cursor-vs-copilot/",
        hours_ago: 15
      },

      # Bezpieczeństwo
      {
        title: "Krytyczna luka w popularnej bibliotece npm - sprawdź swoje projekty",
        url: "https://socket.dev/blog/critical-npm-vulnerability-january-2026",
        hours_ago: 4
      },
      {
        title: "Passkeys w praktyce - jak wdrożyć w Rails/Django/Express",
        url: "https://webauthn.guide/passkeys-implementation",
        hours_ago: 13
      },

      # Polskie
      {
        title: "Programista 15k - historia sukcesu, czy bajka dla juniorów?",
        url: "https://nofluffjobs.com/blog/zarobki-programista-15k-realnosc",
        body: "Analiza rzeczywistych widełek płacowych w polskim IT na podstawie danych z 2025 roku.",
        hours_ago: 6
      },
      {
        title: "Allegro Tech otwiera kod swojego message brokera",
        url: "https://github.com/allegro/hermes",
        hours_ago: 8
      },
      {
        title: "Ask: Jak radzicie sobie z on-callem w polskich firmach?",
        body: "W mojej firmie właśnie wprowadzają dyżury 24/7. Jak to wygląda u was? Płacą dodatkowo? Jak często dzwonią w nocy?",
        hours_ago: 10
      },
      {
        title: "CD Projekt RED szuka Senior Rust Developerów",
        url: "https://jobs.cdprojektred.com/rust-developer",
        body: "Ciekawe, że CDPR idzie w Rust. Może do nowego silnika?",
        hours_ago: 17
      },

      # DevOps/Infra
      {
        title: "Kubernetes 1.32 - co nowego dla developerów",
        url: "https://kubernetes.io/blog/2026/01/kubernetes-1-32/",
        hours_ago: 12
      },
      {
        title: "Nix w produkcji - case study polskiego startupu",
        url: "https://blog.flakm.com/nix-production-case-study",
        hours_ago: 19
      },

      # Eventy
      {
        title: "4Developers 2026 - agenda i bilety",
        url: "https://4developers.org.pl/",
        body: "Największa konferencja IT w Polsce wraca. Tym razem hybrydowo. Early bird do końca stycznia.",
        hours_ago: 14
      },
      {
        title: "Devoxx Poland 2026 - CFP otwarty",
        url: "https://devoxx.pl/cfp-2026/",
        hours_ago: 21
      }
    ]

    created_posts = 0
    posts_data.each do |data|
      next if Post.exists?(url: data[:url]) if data[:url].present?
      next if data[:title] && Post.exists?(title: data[:title])

      post = Post.create!(
        title: data[:title],
        url: data[:url],
        body: data[:body],
        author: bot,
        post_type: data[:url].present? ? :link : :text,
        score: rand(5..30),
        created_at: data[:hours_ago].hours.ago
      )
      post.upvote!(bot)
      created_posts += 1
      puts "Created post: #{data[:title]}"
    end

    # Comments on interesting existing posts
    comments_data = [
      {
        post_id: 165, # Rust vs Go
        body: "Pracuję z oboma językami. Rust świetny do systemówki i CLI, Go do mikroserwisów. W Go szybciej piszesz, w Rust mniej debugujesz na produkcji. Wybór zależy od projektu."
      },
      {
        post_id: 171, # AI Act
        body: "Kluczowe: high-risk AI systems będą wymagały certyfikacji. Większość startupów AI w Polsce będzie musiała dostosować się do wymogów. Kary do 35M EUR lub 7% obrotu."
      },
      {
        post_id: 160, # Weekendowa Lektura
        body: "Z3S to najlepsze źródło o bezpieczeństwie w PL. Polecam też ich podcast i Patronite."
      },
      {
        post_id: 162, # mObywatel kod źródłowy
        body: "Przejrzałem repo - architektura całkiem sensowna. Clean architecture, dobre pokrycie testami. Widać że to nie był projekt robiony na kolanie."
      },
      {
        post_id: 173, # Zarobki w IT
        body: "Raport nie uwzględnia B2B vs UoP. Na B2B 20k netto to jakieś 14k na UoP po kosztach. Porównujmy jabłka do jabłek."
      },
      {
        post_id: 166, # Junior Developer
        body: "Z mojego doświadczenia rekrutacyjnego: juniorzy którzy mają własne projekty na GitHubie (nie tylko tutoriale!) dostają się 3x częściej. Portfolio > certyfikaty."
      },
      {
        post_id: 176, # DDD case study
        body: "DDD ma sens przy złożonej domenie biznesowej. Dla CRUD-a to overengineering. Niestety wiele firm wdraża DDD dla prestiżu, nie z potrzeby."
      },
      {
        post_id: 161, # SantaStealer
        body: "Ciekawy wektor ataku przez Discord webhooks. Pokazuje jak ważne jest nie przechowywanie tokenów w plain text i regularne rotowanie sekretów."
      }
    ]

    created_comments = 0
    comments_data.each do |data|
      post = Post.find_by(id: data[:post_id])
      next unless post

      # Skip if similar comment exists
      next if post.comments.where("body LIKE ?", "%#{data[:body][0..50]}%").exists?

      comment = post.comments.create!(
        body: data[:body],
        author: bot,
        created_at: rand(1..6).hours.ago
      )
      comment.upvote!(bot)
      created_comments += 1
      puts "Created comment on: #{post.title[0..40]}..."
    end

    puts "\nDone! Created #{created_posts} posts and #{created_comments} comments."
  end
end
