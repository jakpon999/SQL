--1. Utworzyć tabelę o nazwie Osoba zawierająca 5 kolumn:
--identyfikator - liczba sześciocyfrowa, autonumeracja od 100000 co 10
--imie - tekst 30 znaków
--nazwisko - tekst 50 znaków
--wiek - liczba trzycyfrowa
--data_dodania - data, domyślnie ma być wstawiana dzisiejsza data

create table osoba(id numeric(6) primary key identity(100000,10),
imie varchar(30),
nazwisko varchar(50),
wiek numeric(3,0),
data_dodania date default getdate());

create table osoba(id numeric(6) identity (100000,10) primary key, 
imie varchar(30),
nazwisko varchar(50),
wiek numeric(3),
data_dodania date default getdate());

-- zad 2
insert into osoba(imie,nazwisko,wiek)
values
('Jan','Kowalski',35),
('Anna','Nowak',30),
('Ewa','Zielińska',38),
('Adam','Woźniak',31);

select * from osoba


--wprowadzenie
create table t(id int)
GO
create trigger t1 
on t 
for INSERT
AS
BEGIN
    declare @liczba as INTEGER
    select @liczba=id from t
    print 'Wstawiono liczbe ' + cast(@liczba as varchar(10))
END
GO
insert into t values(10)
GO

create trigger t2
on T
for INSERT --before, wcześniej wykonywany niż after insert
as
BEGIN
    print 'Trigger T2'
END
insert into t values (20)
GO



create trigger t3
on t
after insert, update, DELETE --nie do końca po insercie update i delete ale pózniej niż for
AS
BEGIN
    print 'Trigger T3'
end 
insert into t values (30)
go


--3. Utworzyć wyzwalacz o nazwie DodanoOsobe na tabeli o nazwie Osoba, 
--który będzie informował użytkownika, że wiersz został dodany. 
--Dodać jeden wiersz do tabeli.

create trigger DodanoOsobe
on osoba
for INSERT
AS
BEGIN
    print 'Wiersz został dodany'
END
insert into osoba(imie,nazwisko,wiek)
VALUES
('Pawel','Rogoza','21')
GO

--3A

create trigger WiekOsoby
on Osoba
for insert
AS
BEGIN
    declare @liczba as INTEGER
    select @liczba=wiek from osoba
    print 'Dodano osobę o wieku: ' + cast(@liczba as varchar(10))
END
insert into osoba (imie,nazwisko,wiek) values ('Paw','Rog','21')

--4. Usunąć wyzwalacz o nazwie DodanoOsobe.
--delete tylko do usuwania wierszy, drop do innych rzeczy

drop trigger DodanoOsobe
drop trigger WiekOsoby

--5. Utworzyć wyzwalacz o nazwie ModyfikujOsobe, 
--który zablokuje możliwość modyfikacji wierszy w tabeli o nazwie Osoba. 
--Wywoływanie instrukcji INSERT na tabeli osoba ma dodatkowo generować wyjątek.
GO
create trigger ModyfikujOsobe
on osoba
for insert, update, delete
AS
BEGIN
    rollback TRANSACTION --wycofuje transakcje, czyli operacje, np modyfikację czy dodanie wiersza.
    raiserror('Osoby nie można modyfikować',1,1) --pokazuje error, surowość na 1 (im wyższa tym większy błąd) i error na 1 (kod błędu).
END
insert into osoba (imie,nazwisko,wiek) values ('tomek','rogoza','21')
select * from osoba



--6. Usunąć wyzwalacz o nazwie ModyfikujOsobe.
GO
drop trigger ModyfikujOsobe

--7. Utworzyć wyzwalacz o nazwie DodanoOsoby na tabeli o nazwie Osoba, 
--który będzie wyświetlał 
--imię i nazwisko nowo dodawanej osoby (wartości). Przetestować działanie.
GO
create trigger DodanoOsoby
on Osoba
for INSERT
AS
BEGIN
    declare @imie as varchar(20)
    declare @nazwisko as varchar(20)
    select @imie=imie from osoba
    select @nazwisko=nazwisko from osoba
    print(@imie + ' ' + @nazwisko)
END
insert into osoba (imie,nazwisko,wiek) values ('tom','rog','21')

--8. Usunąć wyzwalacz o nazwie DodanoOsoby.
drop trigger DodanoOsoby

--9. Utworzyć wyzwalacz o nazwie SprawdzWiek, 
--który zablokuje możliwość 
--wprowadzenia osoby w wieku innymi niż w przedziale 0-120 lat.
GO
create trigger SprawdzWiek
on Osoba
for INSERT, update
AS
BEGIN
    declare @wiek as INTEGER
    select @wiek=wiek from osoba
    if @wiek not between 0 and 120
    BEGIN
        rollback TRANSACTION
        raiserror('Podaj prawidłowy wiek',2,404)
    END
END


--10. Dodać nową osobę w wieku 130 lat. Sprawdzić zawartość tabeli.
insert into osoba (imie,nazwisko,wiek) values ('tosadm','rdasog','211')

--11. Usunąć wyzwalacz o nazwie SprawdzWiek.
GO
drop trigger SprawdzWiek

--12. Zmienić wiek wszystkich osób dodając im 90 lat. 
--Sprawdzić zawartość tabeli.
GO
update osoba set wiek+=90
select * from osoba


--13. Zmienić wiek o 90 lat osobom
--których wiek po zmianie nie przekroczy 120 lat. Sprawdzić zawartość tabeli.

update osoba set wiek+=90
where wiek+90<=120

--14. Utworzyć wyzwalacz DodajDane, 
--który w momencie dodawania danych będzie wyświetlał zawartość tabeli, 
--zgodną z wiekiem wprowadzanych osób.
GO
alter trigger DodajDane
on Osoba
for INSERT
AS
BEGIN
    declare @wiek as INT, @zapytanie as varchar(200)
    select @wiek=wiek from osoba
    set @zapytanie='select * from osoba where wiek = ' + cast(@wiek as varchar(10))
    exec (@zapytanie)
end

insert into osoba (imie,nazwisko,wiek) values ('marek','markowski','111')
select * from osoba

drop trigger DodajDane

--15
GO
create trigger beforeUpdate
on osoba
for insert,update,delete
AS
BEGIN
    select * from osoba
END
insert into osoba (imie,nazwisko,wiek) values ('bogdan','barkowski','21')
update osoba set wiek+=1



--16. Utworzyć nową tabelę o nazwie grupa, 
--która będzie przechowywała informację o numerach grup i numerach studentów. 
--Po dodaniu nowego wiersza powinna się wyświetlać informacja jaki student 
--(z tabeli osoba) został przypisany do grupy, poprzez wyzwalacz GrupaStudencka.
go
create table grupa(numer varchar(10), id numeric(6))

go
create trigger GrupaStudencka
on grupa
for INSERT
AS
BEGIN
    declare @id as numeric(6), @numer as varchar(10),
    @imie varchar(20), @nazwisko varchar(30)
    select @id=id from grupa
    select @numer=numer from grupa
    select @imie=imie, @nazwisko=nazwisko from osoba where id=@id
    print 'Dodano użytkownika ' +cast(@id as varchar(6)) + space(1)+ @imie+space(1)+@nazwisko
END
