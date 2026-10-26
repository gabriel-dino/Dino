# Verificarea versiunii 1.2.0 — 26 octombrie 2026

- Pachet: `ro.dinodesertrun.game`, versiune `1.2.0`, cod `3`.
- Fișier: `dist/Dino-Android.apk`. SHA-256 este inclus în `dist/Dino-Android.apk.sha256`.
- Semnăturile APK v1, v2 și v3 și alinierea la 4 octeți: verificate de scriptul de construire.
- Toate cele 16 module Lua și toate fonturile/licențele din APK și `Dino.love`: comparate octet cu octet cu sursele finale.
- Sintaxa celor 21 de fișiere Lua din rădăcina proiectului: validă.
- `lua tests.lua`, `lua search-tests.lua`, `lua mobile-tests.lua`, `lua feature-tests.lua`: reușite.
- Randare în LÖVE 11.5: toate cele 52.399 de skinuri au nume și imagini distincte (hash-uri SHA-256 ale pixelilor).
- Fructele noi: 12 specii diferite de fructele existente și între ele, toate gratuite. ID-urile vechi, inclusiv Godzilla #52386 și King Kong #52387, sunt păstrate.
- Corpul de T-Rex al fructelor noi: fiecare pixel al corpului comun este prezent în ambele poziții de mers; capul, brațele, coada și picioarele sunt păstrate.
- Cele 10 limbi: traduceri complete, parametri de formatare compatibili, căutare după numele localizat al fiecărui fruct nou și fonturi cu toate caracterele necesare.
- Selectorul de limbă: toate cele 10 opțiuni funcționează cu tastatura (1–9 și 0), mouse și atingere la rezoluții de 1100×680, 640×420 și 1600×720. Limba aleasă persistă după reîncărcare.
- Căutare fără diferențe între majuscule/minuscule: exemple cu diacritice în franceză, germană, turcă și poloneză, inclusiv cele două forme ale literei I în turcă.
- Capturi și inspecție vizuală: selectorul de limbă, planșă cu toate cele 12 fructe noi, ecranele de start, magazin și catalog în cele patru limbi noi. Capturile sunt în `.runtime/qa-images/expanded-*.png`.

Testele noi acoperă prețul de 200 de monede pentru fiecare erou, fondurile insuficiente, cumpărarea unică, salvarea și reîncărcarea, migrarea v1–v3, interdicția cumpărării prin RANDOM, selecția blocată, numărul/pozițiile/înălțimile/intervalele aleatorii ale monedelor, coliziunile personajului mărit, completitudinea traducerilor, căutarea numelor traduse și persistența limbii.

Versiunea 1.2.0 a fost verificată prin teste automate, randare pe Windows și inspecția APK-ului. Nu a fost efectuat un nou test de instalare în emulator sau pe telefon fizic. Versiunea anterioară 1.0.0 fusese instalată și verificată într-un emulator Android 16 / API 36 la 24 octombrie 2026.
