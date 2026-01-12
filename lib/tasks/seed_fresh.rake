namespace :seed do
  desc "Add fresh articles"
  task fresh: :environment do
    bot = User.find_or_create_by!(email: "bot@tabdevs.pl") do |u|
      u.username = "tabdevs-bot"
      u.role = :user
      u.karma = 0
    end

    posts = [
      { title: "SQLite w produkcji - jak Pieter Levels robi miliony na jednej bazie", url: "https://blog.westerndigital.com/sqlite-production-pieter-levels/", hours_ago: 1 },
      { title: "Zig 0.14 - nowy rozdział w systemowym programowaniu", url: "https://ziglang.org/news/zig-0.14-release/", hours_ago: 2 },
      { title: "Turso - SQLite at the edge, czyli baza z latencją 10ms globalnie", url: "https://turso.tech/blog/sqlite-edge-database", hours_ago: 3 },
      { title: "Show: Zbudowałem klon Linktree w weekend za pomocą AI", url: "https://github.com/example/linktree-clone", body: "Stack: Next.js 15, Tailwind, Supabase. Całość z pomocą Claude i Cursor. AMA.", hours_ago: 4 },
      { title: "Dlaczego odszedłem z FAANG do 10-osobowego startupu", url: "https://blog.pragmaticengineer.com/leaving-faang-2026/", hours_ago: 5 },
      { title: "Effect-TS - czy to przyszłość TypeScript?", url: "https://effect.website/blog/effect-3-0/", hours_ago: 6 },
      { title: "Praca zdalna w UE - nowe przepisy od marca 2026", url: "https://ec.europa.eu/remote-work-directive-2026", hours_ago: 7 },
      { title: "Vercel podnosi ceny o 40% - czas na alternatywy?", url: "https://vercel.com/blog/pricing-2026", body: "Coolify, Railway, Fly.io - co wybrać?", hours_ago: 8 },
      { title: "Ask: Kto używa Elixir/Phoenix w produkcji w Polsce?", body: "Rozważam Elixir do nowego projektu. Szukam osób z doświadczeniem w polskich realiach - rekrutacja, utrzymanie, performance.", hours_ago: 9 },
      { title: "React Server Components - rok później, co się sprawdziło?", url: "https://react.dev/blog/2026/01/rsc-one-year-later", hours_ago: 10 },
      { title: "Koniec epoki - Heroku zamyka darmowy tier całkowicie", url: "https://blog.heroku.com/free-tier-sunset-2026", hours_ago: 11 },
      { title: "Svelte 5 Runes - moje doświadczenia po 3 miesiącach", url: "https://dev.to/svelte-5-runes-production-review", hours_ago: 12 },
      { title: "Tauri 2.0 vs Electron - benchmark pamięci i CPU", url: "https://tauri.app/blog/tauri-2-benchmarks/", hours_ago: 13 },
      { title: "Hono.js - najszybszy framework webowy w JS?", url: "https://hono.dev/blog/benchmarks-2026", hours_ago: 14 },
      { title: "Drizzle ORM - dlaczego porzuciłem Prisma", url: "https://orm.drizzle.team/blog/prisma-migration-guide", hours_ago: 15 },
      { title: "GitHub Actions - ukryte koszty i jak je obniżyć", url: "https://devops.com/github-actions-cost-optimization/", hours_ago: 16 },
      { title: "Ask: Jak ogarniacie dokumentację w zespole?", body: "Notion, Confluence, GitBook, markdown w repo? Co działa najlepiej przy 10-20 osobowym zespole?", hours_ago: 17 },
      { title: "Gleam 1.0 - funkcyjny język na BEAM bez kompromisów", url: "https://gleam.run/news/gleam-v1/", hours_ago: 18 },
      { title: "OpenTelemetry w praktyce - observability bez vendor lock-in", url: "https://opentelemetry.io/blog/2026-production-guide/", hours_ago: 19 },
      { title: "tRPC vs GraphQL w 2026 - kiedy który?", url: "https://trpc.io/blog/trpc-vs-graphql-2026", hours_ago: 20 }
    ]

    created = 0
    posts.each do |data|
      next if data[:url].present? && Post.exists?(url: data[:url])
      next if Post.exists?(title: data[:title])

      post = Post.create!(
        title: data[:title],
        url: data[:url],
        body: data[:body],
        author: bot,
        post_type: data[:url].present? ? :link : :text,
        score: rand(8..35),
        created_at: data[:hours_ago].hours.ago
      )
      post.upvote!(bot)
      created += 1
      puts "Created: #{data[:title]}"
    end

    puts "\nDone! Created #{created} posts."
  end
end
