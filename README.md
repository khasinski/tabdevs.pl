# tabdevs.pl

Agregator treści technicznych dla polskich programistów - inspirowany Hacker News.

## Funkcje

- Publikowanie linków i postów tekstowych
- System komentarzy z zagnieżdżaniem
- Głosowanie (upvote/downvote) na posty i komentarze
- System karmy użytkowników
- Zapisywanie postów do zakładek
- Panel administracyjny z moderacją
- Powiadomienia o odpowiedziach i wzmiankach
- Newsletter
- Logowanie przez magic link lub hasło
- Zgodność z GDPR (eksport/usunięcie danych)
- SEO (JSON-LD, sitemap, RSS)
- Ciemny/jasny motyw

## Wymagania

- Ruby 3.3+
- PostgreSQL 16+
- Node.js (dla Tailwind CSS)

## Instalacja

```bash
# Sklonuj repozytorium
git clone https://github.com/khasinski/tabdevs.pl.git
cd tabdevs.pl

# Zainstaluj zależności
bundle install

# Skonfiguruj zmienne środowiskowe
cp .env.example .env
# Edytuj .env i uzupełnij wartości

# Uruchom PostgreSQL (opcjonalnie przez Docker)
docker compose up -d

# Utwórz bazę danych
bin/rails db:create db:migrate

# Uruchom serwer
bin/dev
```

## Zmienne środowiskowe

| Zmienna | Opis |
|---------|------|
| `DATABASE_URL` | URL do bazy PostgreSQL (produkcja) |
| `RESEND_API_KEY` | Klucz API Resend do wysyłki emaili |
| `SECRET_KEY_BASE` | Sekret Rails (wygeneruj przez `bin/rails secret`) |

## Testy

```bash
# Uruchom wszystkie testy
bin/rails test

# Uruchom testy systemowe
bin/rails test:system
```

## Deploy

Projekt jest skonfigurowany do deploymentu na CapRover:

```bash
# Skonfiguruj zmienne w .env.deploy
cp .env.deploy.example .env.deploy

# Deploy
bin/deploy
```

## Struktura projektu

```
app/
├── controllers/
│   ├── admin/          # Panel administracyjny
│   ├── posts_controller.rb
│   ├── comments_controller.rb
│   └── ...
├── models/
│   ├── user.rb
│   ├── post.rb
│   ├── comment.rb
│   └── ...
├── services/
│   ├── notification_service.rb
│   ├── user_export_service.rb
│   └── user_deletion_service.rb
└── views/
```

## Licencja

MIT License - zobacz plik [LICENSE](LICENSE).

## Autor

Chris Hasiński - [@khasinski](https://github.com/khasinski)
