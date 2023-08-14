# COMBAIN TEST

### Example situation: 
You ask the server for userID to then using userID ask for userName

```
func fetchUserId(_ completionHandler: @escaping (Result<Int, Error>) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        let result = 42
        completionHandler(.success(result))
    }
}

func fetchName(for userID: Int, _ completionHandler: @escaping (Result<String, Error>) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        let result = "Matt"
        completionHandler(.success(result))
    }
}


func test() {
    fetchUserId { userIdResult in
        switch userIdResult {
        case .success(let userId):
            fetchName(for: userId) { nameResult in
                switch nameResult {
                case .success(let name):
                    print(name)
                case .failure(let failure):
                    print(failure)
                    break
                }
                
            }
        case .failure(let failure):
            print(failure)
            break
        }
    }
}

    
```

1st think Cyclomatic complexity 2nd Imagine that the code would scale for more queries :/

### SO COMBAIN IS ALL BOUT PROCESSING VALUES OVER TIME 
`import Combine`


```
func searchMovies(for query: String) -> some Publisher<MovieResponse, Error> {
    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery!)")!
    
    return URLSession
        .shared
        .dataTaskPublisher(for: url)
        .map { $0.data }
        .decode(type: MovieResponse.self, decoder: jsonDecoder)
        .eraseToAnyPublisher()
}


```

1. searchMovies(for query: String) -> some Publisher<MovieResponse, Error>: Jest to funkcja, która przyjmuje zapytanie (query) jako tekstowy argument i zwraca Publisher, emitujący obiekty typu MovieResponse lub błędy typu Error.

2. 'let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed): Tutaj zapytanie (query) jest kodowane do formy, która jest bezpieczna do umieszczenia w adresie URL, eliminując potencjalnie niebezpieczne znaki.

3. 'let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery!)")!: Tworzy się URL do zapytania o filmy na podstawie skonstruowanej ścieżki oraz zakodowanego zapytania. W kodzie widoczna jest również zmienna apiKey, która prawdopodobnie jest zdefiniowana wcześniej i zawiera klucz API potrzebny do korzystania z serwisu.

4. 'URLSession.shared.dataTaskPublisher(for: url): Rozpoczyna się żądanie sieciowe za pomocą dataTaskPublisher. Ten Publisher emituje obiekty URLSession.DataTaskPublisher.Output, które zawierają dane i odpowiedzi sieciowe.

5. '.map { $0.data }: Wykorzystując operator map, konwertuje się wyjście Publishera z krotki (data: Data, response: URLResponse) na same dane (data), które są wewnętrznie interesujące w kontekście odpowiedzi serwera.

6. '.decode(type: MovieResponse.self, decoder: jsonDecoder): Używając operacji .decode, dane są dekodowane z formatu JSON na obiekty typu MovieResponse. Wykorzystuje się do tego wcześniej zdefiniowany jsonDecoder.

7. '.eraseToAnyPublisher(): Na koniec, wynikowy Publisher jest "oczyszczany" do typu AnyPublisher<MovieResponse, Error>. To pozwala ukryć rzeczywisty typ Publishera używany w operacjach poprzednich, dostarczając jedynie ogólny interfejs Publishera.


Podsumowując, funkcja searchMovies(for:) *tworzy Publisher,* który wysyła zapytanie do serwera o filmy na podstawie zapytania użytkownika, pobiera odpowiedź w postaci danych, dekoduje te dane do obiektów typu MovieResponse i dostarcza je jako emitowane wartości Publishera. Operacja .eraseToAnyPublisher() jest używana do ukrycia rzeczywistego typu Publishera i dostarczenia ogólnego interfejsu.

```
    func fetchInitialData() {
        fetchMovies()
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] movies in
                self?.upcommingMovies = movies
            }
            .store(in: &cancelables)

    }
```

## Funkcja fetchInitialData()

Funkcja `fetchInitialData()` służy do pobrania początkowych danych związanych z filmami. Wykonuje ona następujące kroki:

1. **fetchMovies()**: Rozpoczyna żądanie sieciowe w celu pobrania danych dotyczących filmów za pomocą funkcji `fetchMovies()`. Wynik jest typem Publishera.

2. **map(\.results)**: Operator `map` przetwarza emitowane przez Publishera dane. W tym przypadku, wykorzystuje się skróconą składnię `\.results`, aby wyodrębnić pole `results` z otrzymanych danych. To skutkuje emitowaniem samej tablicy wyników filmów.

3. **receive(on: DispatchQueue.main)**: Operator `receive` umożliwia odbieranie wartości Publishera na określonym planerze (scheduler). W tym przypadku, wynikowe wartości będą odbierane na głównym wątku (DispatchQueue.main), co umożliwia aktualizację interfejsu użytkownika.

4. **sink(completion:receiveValue:)**: Operator `sink` jest używany do obsługi zarówno wartości emitowanych przez Publishera, jak i zdarzeń zakończenia (completion). Jeśli Publisher emituje wartość, zostanie to obsłużone w bloku `receiveValue`, gdzie następuje przypisanie pobranych filmów do właściwości `upcommingMovies`. W przypadku błędu, blok `failure` wypisuje opis błędu.

5. **store(in: &cancelables)**: Funkcja `store(in:)` jest używana do przechowywania subskrypcji w kolekcji `cancelables`, aby można było ją później anulować (cancel) w celu zarządzania cyklem życia subskrypcji i uniknięcia wycieków pamięci.

W rezultacie, funkcja `fetchInitialData()` wywołuje funkcję `fetchMovies()`, przetwarza wynikowe dane, obsługuje błędy i aktualizuje właściwość `upcommingMovies`, która prawdopodobnie jest częścią większego systemu. Operacje są wykonywane w sposób asynchroniczny i uwzględniają zarządzanie wątkami oraz cyklem życia subskrypcji.
