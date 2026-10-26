# DINO pentru Android

APK-ul instalabil este generat în `android/dist/Dino-Android.apk`. Include jocul și motorul LÖVE 11.5a; nu necesită instalarea separată a LÖVE și funcționează offline.

## Instalare și comenzi

1. Copiază APK-ul pe telefon și deschide-l din aplicația Fișiere.
2. Permite instalarea din acea aplicație dacă Android solicită acest lucru, apoi apasă Instalare.
3. Deschide **DINO - Desert Run**. Jocul rulează pe orizontală, în ambele orientări.

- Atinge zona de joc sau **JUMP** pentru start, săritură și restart după pierdere. Eliberează devreme pentru o săritură mai scurtă.
- Ține apăsat **DUCK** pentru aplecare. Poți apăsa **JUMP** cu alt deget; eliberarea unui buton nu îl eliberează pe celălalt.
- **PAUSE / RESUME**, **RESET**, **SOUND ON / OFF** și **UPGRADES** sunt disponibile pe ecran.
- Atinge bara de skin-uri pentru catalog, apoi câmpul de căutare pentru tastatura Android. Atinge un skin pentru selecție, **NEXT / PREVIOUS** pentru pagini și **CLOSE** pentru închidere.
- Butonul Android Înapoi închide catalogul, magazinul sau selectorul de limbă și pune cursa pe pauză în joc. Închiderea tastaturii poate consuma prima apăsare.
- Revenirea din fundal păstrează jocul pe pauză; atinge zona de joc pentru continuare.

Apasă **Language / 语言** pentru română, engleză (implicită), chineză simplificată, italiană, portugheză, spaniolă, franceză, germană, turcă sau poloneză. Toate cele 10 opțiuni încap pe ecran, iar alegerea se salvează. Personajul este mărit cu 35%, iar colecția include 23 de skin-uri de fructe și eroii Godzilla și King Kong, fiecare la 200 de monede. Cele 12 fructe noi sunt căpșună, kiwi, ananas, cireașă, strugure, lămâie, cocos, fructul dragonului, afină, zmeură, rodie și avocado. Sunt gratuite și păstrează corpul de T-Rex.

Recordul, monedele, misiunile, upgrade-urile, eroii cumpărați, limba și skin-ul ales se salvează local. Salvările de pe calculator nu sunt transferate automat pe telefon. Dezinstalarea poate șterge datele aplicației.

## Reconstruire pe Windows

Necesită Java JDK 17 sau mai recent, Android SDK cu Build Tools și PowerShell. Setează `ANDROID_HOME` sau transmite `-SdkRoot`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File android\build.ps1
```

La prima rulare, scriptul descarcă din proiectele oficiale LÖVE Android 11.5a (varianta embed) și APKTool 3.0.3. Verifică SHA-256 pentru ambele. Copiază numai modulele jocului, aplică identitatea `ro.dinodesertrun.game`, numele, pictograma și orientarea, apoi reconstruiește, aliniază, semnează și verifică APK-ul. APK-ul nu declară permisiuni de internet, microfon sau stocare partajată. Licențele motorului și bibliotecilor sale sunt incluse în assets.

Fișierele temporare și instrumentele sunt în `.runtime/android`. **Păstrează împreună `dino-signing.jks` și `dino-signing.password`**, într-un loc privat, pentru a semna viitoarele actualizări cu aceeași cheie. Aceste fișiere nu sunt incluse în APK. Pentru o actualizare distribuită, mărește și `versionCode` / `versionName` în script. Fișierul `Dino-Android.apk.sha256` permite verificarea integrității APK-ului.

Pachetul folosește motorul oficial precompilat pentru **ARM64 și ARMv7**, cu versiunea minimă Android declarată de acesta, **Android 4.1 / API 16**. Acest lucru nu înseamnă că fiecare model de telefon a fost testat. Distribuția este un APK pentru instalare directă; publicarea pe Google Play și suportul nativ pentru pagini de memorie de 16 KB necesită un flux separat cu o versiune adecvată a motorului.

## Verificări locale

```powershell
lua tests.lua
lua search-tests.lua
lua mobile-tests.lua
lua feature-tests.lua
```

Documentația oficială pentru [distribuția LÖVE pe Android](https://love2d.org/wiki/Game_Distribution#Android) și [motorul Android 11.5a](https://github.com/love2d/love-android/releases/tag/11.5a).
