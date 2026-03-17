# Portfolio Kryptowalut (PWA)

Aplikacja do śledzenia wartości portfolio kryptowalut. Działa w przeglądarce i **można ją zainstalować na telefonie** (jak aplikacja).

## Jak uruchomić

1. **Lokalnie (komputer):**  
   Otwórz plik `index.html` w przeglądarce (Chrome, Edge) – np. dwuklik albo przeciągnij plik do okna przeglądarki.

2. **Lepiej – przez serwer:**  
   Żeby działało „Zainstaluj aplikację” i API cen, uruchom z folderu `crypto-portfolio-pwa` prosty serwer:
   - **Python 3:** `python -m http.server 8080`
   - Potem w przeglądarce: **http://localhost:8080**

## Instalacja na telefonie (jak Phantom)

1. Wgraj folder `crypto-portfolio-pwa` na swój serwer (hosting, VPS) albo użyj np. **GitHub Pages** / **Netlify** – wtedy adres będzie np. `https://twoja-strona.github.io/portfolio`.
2. Na telefonie otwórz **Chrome** (Android) lub **Safari** (iPhone) i wejdź na ten adres.
3. **Android (Chrome):** Menu (⋮) → „Zainstaluj aplikację” / „Dodaj do ekranu początkowego”.
4. **iPhone (Safari):** Przycisk „Udostępnij” → „Dodaj do ekranu początkowego”.

Po instalacji ikona pojawi się na ekranie – otwierasz jak zwykłą aplikację.

## Co robi aplikacja

- **Dodawanie pozycji:** wybierz kryptowalutę (BTC, ETH, SOL, itd.) i ilość → „Dodaj”.
- **Aktualne ceny:** z CoinGecko (USD i PLN).
- **Suma portfolio** na górze w USD i PLN.
- **Dane w telefonie:** zapis w przeglądarce (localStorage) – nie wysyłamy ich na żaden serwer.
- **Usuwanie:** przy każdej pozycji jest „Usuń”.

## Ikony (opcjonalnie)

W `manifest.json` są wpisy `icon-192.png` i `icon-512.png`. Jeśli dodasz takie pliki do folderu, system użyje ich przy instalacji. Bez nich przeglądarka użyje domyślnej ikony.
