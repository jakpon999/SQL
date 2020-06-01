
--1. sprawdzić swoje uprawnienia na serwerze SQL
select * from sys.fn_my_permissions(default, 'SERVER')

--2. Sprawdzić swoje uprawnienia w bazie danych SQL.
select * from sys.fn_my_permissions(default, 'DATABASE')

--3. Utworzyć tabelę o nazwie Towar, zawierająca cztery kolumny:
-- identyfikator, liczba, autoinkrementacja, klucz główny
-- nazwa towaru, tekst, 20 znaków
-- cena, waluta
-- data dodania, data
create table Towar(
    id int identity(1,1) PRIMARY KEY,
    nazwa varchar(20),
    cena money,
    data_dodania DATE default getdate()
)
select * from Towar

--4. Wykorzystując autoinkrementację dodać do tablicy Towar trzy wiersze:
-- Ołówek; 1,29 zł
-- Kredka; 0,52 zł
-- Długopis; 1,32 zł
insert into Towar (nazwa, cena) VALUES
('ołówek', 0.52),
('kredka', 0.52),
('długopis', 1.32)

--5. Zmienić uprawnienia na tabeli usuwając 
-- innemu użytkownikowi możliwość przeglądania zawartości tabeli.
use master
GO

create login s1231 with password='student'
create user s1231 for login s1231
go
exec sp_addrolemember @membername='s1231', @rolename='db_datareader'
go
deny select on towar to s1231

--6. Sprawdzić swoje uprawnienia na obiekcie innego użytkownika.
exec sp_helprotect null, 's1231'

--7. Cofnąć przyznane zablokowane wcześniej uprawnienie do obiektu. 
--Sprawdzić działanie.
revoke select on towar to s1231
exec sp_helprotect null, 's1231'

--8. Zablokować uprawnienia aktualizacji, 
--dodawania wierszy oraz zmian w tablicy Towar dla innego użytkownika.
deny insert,alter,update on towar to s1231
exec sp_helprotect null, 's1231'

--9. Nadać możliwość dodawania wierszy w tablicy Towar dla innych użytkowników. 
--Sprawdzić działanie i efektywne uprawnienia na tabeli Towar.
grant insert on towar to s1231
exec sp_helprotect null, 's1231'

--10. Spróbowac
--zablokować wszystkie uprawnienia na obiekcie Towar dla innego użytkownika.
deny all on towar to s1231
exec sp_helprotect null, 's1231'

--11. Sprawdzić jaki będzie dzień za 100 dni.
select DATEADD(dd, 100, getdate())

--12. Wyświetlić zawartość tabeli Towar, 
--wypisując w czwartej kolumnie dzień tygodnia w jakim towar został dodany.
select id, nazwa, cena, DATENAME(DW, data_dodania) as 'Dzień tygodnia' from Towar

--13. Wyświetlić w osobnych kolumnach: 
--nazwę towaru, cenę, dzień dodania, miesiąc dodania słownie, rok.
select nazwa, cena, DATENAME(DW, data_dodania) as 'Dzień tygodnia',
DATENAME(mm, data_dodania) as 'Miesiąc', DATENAME(yy, data_dodania) as 'Rok' from Towar

--14. Sprawdzić ile dni dzieli bieżącą datę od 1 października bieżącego roku.
select DATEDIFF(dd, getdate(), '2020-10-01')

--15. Dodać dwa kolejne wiersze do tabeli o następujących wartościach:
--Mazak czerwony; NULL
--Mazak zielony; NULL
insert into Towar (nazwa, cena) VALUES
('mazak czerwony', null),
('mazak zielony)', null)

select * from Towar

--16. Wyświetlić zawartość tabeli Towar, jeżeli cena
-- ma wartość NULL to powinna wyświetlić się 9,99 zł.
select nazwa, data_dodania, isnull(cena,9.99) as 'Cena' from towar

--17. Utworzyć typ tablicowy o nazwie T_Czas, 
--który będzie przechowywać liczby i odpowiadające im wartości miesięcy.
create type t_czas as table (id int, nazwa varchar(20))

create table t1 (id int, b t_czas)

--18. Utworzyć procedurę o nazwie WyswietlTowary, 
--która przy pomocy typu tablicowego T_Czas 
--będzie wyświetlała poszczególne nazwy towarów i słownie miesięcy,
-- w których zostały dodane.
go
alter procedure WyswietlTowary
as
BEGIN
    declare @tc t_czas
    insert into @tc values (1,'styczeń'), (3,'marzec'), (5,'maj')
    --select * from @tc
    declare @miesiac varchar(20), @towar varchar(30), @licznik INT
    set @licznik=1
    while @licznik<5
    BEGIN
        select @towar=t.nazwa, @miesiac=c.nazwa from towar t, @tc c 
        where c.id=month(data_dodania) and t.id=@licznik
        print @towar + space(1) + @miesiac
        set @licznik+=1
    END
end
exec WyswietlTowary

--19. Zablokować uprawnienia wykonania procedury 
--dla innych użytkowników i przetestować działania.
deny execute on WyswietlTowary to s1231
exec sp_helprotect null, 's1231'

--20. Utworzyć rolę o nazwie Rola_Towar i 
--przypisać jej pełne uprawnienia do tabeli Towar.
create role Rola_Towar
GO
grant all on towar to Rola_Towar
GO
sp_helprole


--21. Do roli Rola_Towar przypisać 
--uprawnienia wykonywania procedury o nazwie WyswietlTowary.
grant execute on wyswietltowary to rola_towar



--22. Przypisać rolę Rola_Towar własnemu użytkownikowi. 
--Sprawdzić użytkowników przypisanych do roli.
exec sp_addrolemember @rolename='rola_towar', @membername='s1231'
exec sp_helprolemember
