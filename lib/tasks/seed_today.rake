namespace :seed do
  desc "Add today's news articles from various sources"
  task today: :environment do
    bot = User.find_or_create_by!(email: "bot@tabdevs.pl") do |u|
      u.username = "tabdevs-bot"
      u.role = :user
      u.karma = 0
    end

    posts_data = [
      # === HACKER NEWS TOP ===
      {
        title: "ACM: Wszystkie publikacje będą open access od 2026",
        url: "https://www.acm.org/publications/policies/open-access",
        body: "ACM ogłosiło, że wszystkie publikacje staną się open access. Przełom dla świata naukowego.",
        hours_ago: 1
      },
      {
        title: "Netflix przejmuje Warner Bros",
        url: "https://www.theverge.com/netflix",
        body: "Mega-fuzja w branży rozrywkowej. Netflix staje się jeszcze większym gigantem streamingu.",
        hours_ago: 2
      },
      {
        title: "Ghostty staje się organizacją non-profit",
        url: "https://ghostty.org/",
        body: "Terminal GPU-accelerated od Mitchella Hashimoto przechodzi pod opiekę Hack Club.",
        hours_ago: 3
      },
      {
        title: "Teksas pozywa producentów telewizorów za szpiegowanie widzów",
        url: "https://www.texasattorneygeneral.gov/",
        body: "Pozew przeciwko LG, Samsung i innym za zbieranie danych o oglądanych treściach.",
        hours_ago: 5
      },
      {
        title: "IPv6 ma 30 lat i nadal nie zdominowało internetu",
        url: "https://www.rfc-editor.org/rfc/rfc2460",
        body: "Refleksja nad adopcją IPv6 - dlaczego przejście trwa tak długo?",
        hours_ago: 7
      },

      # === NARZĘDZIA DEV ===
      {
        title: "Windsurf vs Cursor: Porównanie AI IDE w 2026",
        url: "https://www.builder.io/blog/windsurf-vs-cursor",
        body: "OpenAI kupiło Windsurf za $3B. Który edytor AI jest lepszy dla programistów?",
        hours_ago: 1
      },
      {
        title: "Ghostty 1.2 - nowe funkcje i wsparcie macOS Tahoe",
        url: "https://ghostty.org/docs/install/release-notes/1-2-0",
        body: "6 miesięcy pracy, 149 kontrybutorów, 2676 commitów. Pierwszy terminal z progress barami na macOS.",
        hours_ago: 4
      },
      {
        title: "Node.js vs Deno vs Bun w 2026 - który runtime wybrać?",
        url: "https://dev.to/pockit_tools/deno-2-vs-nodejs-vs-bun-in-2026-the-complete-javascript-runtime-comparison-1elm",
        body: "Bun wygrywa wydajnością 3-4x, Deno 2 ma kompatybilność z npm, Node.js pozostaje standardem enterprise.",
        hours_ago: 6
      },

      # === BAZY DANYCH ===
      {
        title: "PostgreSQL 18 - asynchroniczne I/O i 3x szybsze odczyty",
        url: "https://www.postgresql.org/about/news/postgresql-18-released-3142/",
        body: "Wirtualne kolumny generowane, OAuth, temporal constraints. Największy upgrade wydajności.",
        hours_ago: 2
      },
      {
        title: "Tiger Data: BM25 Search dla PostgreSQL jako open source",
        url: "https://itsfoss.com/news/tiger-data-pg-textsearch/",
        body: "Pełnotekstowe wyszukiwanie jakości Elasticsearch, ale w PostgreSQL.",
        hours_ago: 8
      },

      # === LINUX / KERNEL ===
      {
        title: "Linux 6.18 LTS - Rust GPU driver dla Mali, wsparcie Apple Silicon",
        url: "https://www.phoronix.com/news/Linux-Kernel-Highlights-2025",
        body: "Tyr driver w Rust, device trees dla M2 Pro/Max/Ultra, wsparcie Snapdragon X1 laptopów.",
        hours_ago: 3
      },
      {
        title: "Bcachefs usunięty z kernela Linux 6.18",
        url: "https://lwn.net/",
        body: "Linus Torvalds oznaczył Bcachefs jako 'externally maintained', teraz kod usunięty z mainline.",
        hours_ago: 9
      },

      # === JĘZYKI PROGRAMOWANIA ===
      {
        title: "Zig może odebrać Rustowi koronę wydajności",
        url: "https://medium.com/@yashbatra11111/zig-can-come-for-rusts-performance-crown-and-it-might-win-10ca15bd6b0e",
        body: "Zig w 2025 przestał być hipotetyczny. Porównanie z Rust i Go dla systems programming.",
        hours_ago: 4
      },
      {
        title: "Go vs Rust vs Zig - przemyślenia po użyciu wszystkich trzech",
        url: "https://sinclairtarget.com/blog/2025/08/thoughts-on-go-vs.-rust-vs.-zig/",
        body: "Żaden z tych języków nie implementuje class-based OOP. Co to oznacza dla przyszłości?",
        hours_ago: 10
      },

      # === SELF-HOSTED / OPEN SOURCE ===
      {
        title: "50+ open-source alternatyw dla usług chmurowych w 2026",
        url: "https://www.dreamhost.com/blog/open-source-alternatives/",
        body: "Od email po streaming - jak zastąpić SaaS własnymi rozwiązaniami.",
        hours_ago: 5
      },
      {
        title: "VaultWarden, Focalboard, LoggiFly - najlepsze self-hosted apps 2025",
        url: "https://selfh.st/post/2025-favorite-new-apps/",
        body: "Przegląd najciekawszych aplikacji do self-hostingu z minionego roku.",
        hours_ago: 11
      },

      # === POLSKA / CYBERBEZPIECZEŃSTWO ===
      {
        title: "CERT Polska: Dwukrotny wzrost incydentów w 2025",
        url: "https://cyberdefence24.pl/cyberbezpieczenstwo/cert-polska-dwukrotny-wzrost-incydentow-w-2025-roku",
        body: "Polska jednym z najintensywniej atakowanych krajów. Nowa funkcja 'Powierzchnia ataku' w moje.cert.pl.",
        hours_ago: 2
      },
      {
        title: "Co piąty pracownik polskiej firmy był ofiarą cyberataku",
        url: "https://niebezpiecznik.pl/",
        body: "Raport ESET/DAGMA: tylko 59% firm używa antywirusa, 2FA jeszcze rzadziej.",
        hours_ago: 6
      },
      {
        title: "KSeF i kryptografia postkwantowa - wyzwania 2026",
        url: "https://spolecznosc.payload.pl/wojna-hybrydowa-ksef-i-kryptografia-postkwantowa-to-glowne-wyzwania-cyberbezpieczenstwa-na-2026-rok-36377655.html",
        body: "Krajowy System e-Faktur jako sprawdzian dojrzałości cyberbezpieczeństwa państwa.",
        hours_ago: 12
      },

      # === WYDARZENIA ===
      {
        title: "WordUp Kraków - styczeń 2026",
        url: "https://crossweb.pl/en/events/wordup-krakow-styczen-2026/",
        body: "Meetup WordPress, 12 stycznia 2026, Politechnika Krakowska. 3 prelekcje + networking.",
        hours_ago: 8
      },
      {
        title: "Prague PostgreSQL Developer Day 2026",
        url: "https://www.postgresql.org/about/events/",
        body: "27-28 stycznia 2026. Konferencja dla deweloperów PostgreSQL w Pradze.",
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
        score: 1,
        created_at: data[:hours_ago].hours.ago
      )
      created += 1
      puts "Created: #{data[:title]}"
    end

    puts "Done! Created #{created} posts."
  end
end
