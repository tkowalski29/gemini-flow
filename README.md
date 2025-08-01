# Gemini Flow

## Opis projektu

Gemini Flow to system automatyzacji zadań wykorzystujący Google Gemini AI do analizy i przetwarzania zadań projektowych. Projekt integruje się z Raycast i obsługuje różne typy zadań, w tym analizę projektów Figma oraz zadania projektowe typu "epic".

## Architektura rozwiązania

### Struktura katalogów

```
gemini-flow/
├── commands/           # Instrukcje dla różnych typów zadań
│   ├── epic.md        # Instrukcje dla zadań projektowych
│   └── figma.md       # Instrukcje dla analizy Figma
├── config/            # Konfiguracje
│   └── gemini/        # Konfiguracje Gemini AI
│       └── figma.json # Konfiguracja MCP dla Figma
├── script/            # Skrypty pomocnicze
│   └── common.sh      # Wspólne funkcje dla wszystkich skryptów
├── spec/              # Zadania do przetwarzania
│   ├── t1/           # Zadanie 1
│   │   ├── task.md    # Plik z treścią zadania
│   │   └── sessions/  # Katalog z sesjami (generowany automatycznie)
│   │       ├── 1/     # Sesja 1
│   │       │   ├── session.json     # Metadane sesji
│   │       │   ├── task.md          # Kopia zadania
│   │       │   ├── instructions.md  # Kopia instrukcji
│   │       │   └── result.md        # Wygenerowana odpowiedź
│   │       └── 2/     # Sesja 2 (kolejne uruchomienia)
│   ├── t2/           # Zadanie 2 (struktura analogiczna)
│   └── t3/           # Zadanie 3 (struktura analogiczna)
├── epic.sh           # Skrypt Raycast dla zadań epic
└── figma.sh          # Skrypt Raycast dla analizy Figma
```

**Uwaga**: Pliki w katalogach `commands/`, `config/` i `spec/` są ignorowane przez `.gitignore` i nie są widoczne w repozytorium. Są one generowane lokalnie podczas działania systemu.

### Komponenty systemu

#### 1. Skrypty Raycast (`epic.sh`, `figma.sh`)
- **Cel**: Integracja z Raycast dla szybkiego dostępu do funkcji
- **Parametry**:
  - `Folder ID`: Identyfikator zadania (np. t1, t2, t3)
  - `Open file`: Opcja otwarcia wygenerowanego pliku
- **Funkcjonalność**: Automatyczne tworzenie sesji i przetwarzanie zadań

#### 2. System sesji
- **Automatyczne numerowanie**: Każde uruchomienie tworzy nową sesję
- **Struktura sesji**:
  ```
  spec/{task_id}/sessions/{session_number}/
  ├── session.json     # Metadane sesji
  ├── task.md          # Kopię oryginalnego zadania
  ├── instructions.md  # Kopię instrukcji
  └── result.md        # Wygenerowana odpowiedź
  ```

#### 3. Konfiguracja Gemini
- **Plik konfiguracyjny**: `config/gemini/figma.json`
- **Integracja MCP**: Obsługa Figma DevMode przez SSE
- **Automatyczne kopiowanie**: Konfiguracja jest kopiowana do `~/.gemini/settings.json`

#### 4. Instrukcje zadań
- **epic.md**: Instrukcje dla zadań projektowych z naciskiem na prawdę i design
- **figma.md**: Instrukcje dla analizy projektów Figma z wykorzystaniem MCP

### Typy zadań

#### Epic Tasks
- **Cel**: Analiza zadań projektowych
- **Fokus**: Prawda, dokładność, design excellence
- **Zasady**: 
  - Priorytet faktów nad interpretacją
  - Odwołania do sprawdzonych wzorców projektowych
  - Uwzględnienie dostępności i inkluzywności

#### Figma Analysis
- **Cel**: Analiza projektów Figma
- **Narzędzia**: Figma DevMode MCP
- **Funkcjonalność**:
  - Analiza struktury komponentów
  - Wykrywanie problemów (brak nazw, puste teksty)
  - Integracja przez SSE URL: `http://localhost:3845/sse`

## Zarządzanie systemem

### Jak system przechowuje pliki

System automatycznie zarządza plikami na Twoim komputerze. Niektóre pliki są widoczne w internecie (repozytorium), a inne tylko na Twoim komputerze.

**Pliki tylko na Twoim komputerze** (nie są wysyłane do internetu):
- Twoje zadania i ich treść
- Wyniki analiz
- Ustawienia systemu
- Instrukcje dla sztucznej inteligencji

**Dlaczego tak jest?**
- Twoje zadania są prywatne
- Wyniki analiz mogą zawierać poufne informacje
- Każdy użytkownik ma swoje własne ustawienia

### Dodawanie nowych zadań

**Ważne**: Pliki zadań są przechowywane tylko na Twoim komputerze i nie są wysyłane do internetu.

#### Krok po kroku:

1. **Wejdź do katalogu projektu**:
   - Otwórz Terminal (lub wiersz poleceń)
   - Przejdź do folderu gdzie masz pobrany projekt Gemini Flow

2. **Utwórz katalog z zadaniem**:
   - W folderze `spec` utwórz nowy folder z nazwą Twojego zadania
   - Na przykład: folder `moje-zadanie` lub `analiza-strony`

3. **Utwórz plik task.md**:
   - W nowo utworzonym folderze utwórz plik o nazwie `task.md`
   - Możesz to zrobić w edytorze tekstu lub przez Terminal

4. **Dodaj treść zadania**:
   - Otwórz plik `task.md` w swoim edytorze tekstu (np. Notatnik, VS Code, TextEdit)
   - Napisz co chcesz, żeby system przeanalizował

5. **Uruchom analizę**:
   - W Terminalu wpisz: `./epic.sh nazwa-twojego-folderu 1` (aby otworzyć wynik w edytorze)
   - Lub: `./epic.sh nazwa-twojego-folderu 0` (bez otwierania wyniku)

#### Przykład:

**Struktura folderów:**
```
spec/
├── moje-zadanie/
│   └── task.md
└── analiza-strony/
    └── task.md
```

**Zawartość pliku `task.md`:**
```
# Moje zadanie

Sprawdź czy ta strona internetowa jest przyjazna dla osób z niepełnosprawnościami.
Zwróć uwagę na:
- Czy tekst jest czytelny
- Czy można nawigować klawiaturą
- Czy obrazy mają opisy
```

**Uruchomienie:**
```
./epic.sh moje-zadanie 1
```

### Monitorowanie sesji

- **Lokalizacja sesji**: `spec/{task_id}/sessions/{session_number}/`
- **Metadane**: `session.json` zawiera informacje o statusie i czasie utworzenia
- **Wyniki**: `result.md` zawiera wygenerowaną odpowiedź z timestampem

### Co potrzebujesz do uruchomienia systemu

#### Programy, które musisz mieć:
- **Google Gemini CLI** - program do komunikacji ze sztuczną inteligencją
- **Raycast** (opcjonalnie) - program do szybkiego dostępu do funkcji
- **Figma DevMode** (tylko jeśli chcesz analizować projekty Figma)

#### Pierwsze uruchomienie:
1. **Zainstaluj Google Gemini CLI** (jeśli jeszcze nie masz)
2. **Uruchom Figma DevMode** (jeśli chcesz analizować Figma)
3. **System automatycznie skonfiguruje się** przy pierwszym uruchomieniu

#### Jeśli chcesz analizować projekty Figma:
1. Otwórz Figma
2. Włącz tryb dewelopera (DevMode)
3. System automatycznie połączy się z Figma

### Dodawanie nowych funkcji (dla programistów)

Jeśli chcesz dodać nowe typy zadań lub zmienić sposób działania systemu:

#### Dodanie nowego typu zadania:
1. Utwórz nowy plik skryptu (np. `nowe-zadanie.sh`)
2. Dodaj instrukcje w `commands/nowe-zadanie.md`
3. Skonfiguruj system jeśli potrzebne

#### Zmiana instrukcji:
- Edytuj pliki w folderze `commands/`
- Zmiany będą automatycznie używane w nowych zadaniach

## Jak to działa - krok po kroku

1. **Przygotowanie**: Napisz swoje zadanie w pliku tekstowym
2. **Uruchomienie**: Uruchom program analizujący
3. **Przetwarzanie**: Sztuczna inteligencja analizuje Twoje zadanie
4. **Wynik**: Otrzymujesz gotową analizę w pliku tekstowym

**Przykład:**
- Napiszesz: "Sprawdź czy ta strona jest przyjazna dla osób z niepełnosprawnościami"
- System przeanalizuje i odpowie: "Znalazłem 5 problemów z dostępnością..."

## Bezpieczeństwo i najlepsze praktyki

- **Izolacja sesji**: Każda sesja jest niezależna
- **Backup**: Oryginalne pliki zadań są kopiowane do sesji
- **Logowanie**: Wszystkie operacje są logowane z timestampami
- **Konfiguracja**: Automatyczne zarządzanie konfiguracją Gemini

### Backup i zarządzanie danymi

**Ważne**: Pliki w katalogach `commands/`, `config/` i `spec/` nie są commitowane do repozytorium ze względu na `.gitignore`. 

**Zalecane praktyki**:
- Regularnie twórz backup lokalnych plików konfiguracyjnych
- Używaj systemu kontroli wersji dla własnych plików zadań
- Dokumentuj zmiany w konfiguracji

**Backup konfiguracji**:
```bash
# Utwórz backup plików konfiguracyjnych
tar -czf gemini-flow-config-backup-$(date +%Y%m%d).tar.gz \
  commands/ config/ spec/

# Przywróć z backupu
tar -xzf gemini-flow-config-backup-20241201.tar.gz
```

## Rozwiązywanie problemów

### System nie działa
**Sprawdź czy masz:**
- Zainstalowany Google Gemini CLI
- Połączenie z internetem
- Uprawnienia do zapisu plików

### Problem z Figma
**Jeśli chcesz analizować projekty Figma:**
1. Upewnij się, że Figma jest otwarta
2. Sprawdź czy tryb dewelopera (DevMode) jest włączony
3. Spróbuj ponownie uruchomić analizę

### Problem z plikami
**Jeśli system nie może zapisać wyników:**
1. Sprawdź czy masz miejsce na dysku
2. Sprawdź czy masz uprawnienia do folderu
3. Spróbuj uruchomić Terminal jako administrator

### Nie wiesz co robić?
1. Sprawdź czy wszystkie programy są zainstalowane
2. Upewnij się, że postępujesz zgodnie z instrukcjami
3. Jeśli problem nadal występuje, skontaktuj się z programistą
