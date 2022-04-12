# ARKO Projekt x86 - Rysowanie 5-punktowej krzywej beziera

Program jest kompilowany przy użyciu narzędzia make więc aby go skompilować nalezy użyć polecenia:
``` 
make all 
```

Po uruchomieniu programu ``` bezier ``` pokazuje nam się białe tło na które możemy klikać, aby zacząć rysować krzywą. Po narysowaniu 5-punktowej krzywej tło się resetuje i możemy rysować od początku. Każda zmiana zapisuje się do pliku ``` result.bmp ```.


### Znaczenie rejestrów (dla systemu linux):
Rejestry stałoprzecinkowe:
- rax - stałoprzecinkowe x
- rbx - stałoprzecinkowe y
- rcx - liczba punktów
- r9 - adres początku bitmapy
- r10 - adres pixela
- r11 - kopia rcx przydatna w kilku funkcjach jako licznik
- r12 - ilość bajtów w rzędzie
- r13 - ilość bajtów w pixelu

Rejestry zmiennoprzecinowe:
- xmm0 - licznik dla funkcji zmiennoprzecinkowej
- xmm1 - stała jedynka dla funcki zmiennoprzecinkowej
- xmm2 - współczynnik t we wzorze na krzywą beziera
- xmm3 - (1 - t) potrzebne do wzoru na krzywą beziera
- xmm4 - xmm10 - zmienne zależne od funkcji (podane punkty, wynik, zmienna tymczasowa potrzebna do wyliczeń)

Zmienne przekazywane do rejestrów:
- rdi - tablica zawierająca współrzędne x
- rsi - tablica zawierająca współrzędne y
- rdx - tablica pixeli
- rcx - liczba podanych punktów
- r8 - tablica zawierająca resztę potrzebnych danych (współczynnik t, ilość bajtów w rzędzie, ilość bajtów w pixelu)