--   drop table Genre, Performers, Albums, Genre_Performers, Performers_Albums, Tracks, Compilation, Compilation_Tracks;

create table if not exists Genre(
    Id serial primary key, 
    Name varchar(40) not null unique);

create table if not exists Performers (
    Id serial primary key, 
    Nickname varchar(40) not null);

create table if not exists Genre_Performers (
    Id serial,
    Genre_id integer not null references Genre(Id), 
    Performers_id integer not null references Performers(Id), 
    constraint pk1 primary key (Genre_id, Performers_id));

create table if not exists Albums (
    Id serial primary key, 
    Name varchar(100) not null, 
    Release integer not null);

create table if not exists Performers_Albums (
    Id serial,
    Performers_id integer not null references Performers(Id), 
    Albums_id integer not null  references Albums(Id), 
    constraint pk2 primary key (Performers_id, Albums_id));

create table if not exists Tracks (
    Id serial primary key, 
    Name varchar(100) not null, 
    Duration numeric not null,
    Albums_id integer references Albums(Id));

create table if not exists Compilation (
    Id serial primary key, 
    Name varchar(100) not null, 
    Release integer not null);

create table if not exists Compilation_Tracks (
    Id serial,
    Compilation_id integer not null references  Compilation(Id), 
    Tracks_id integer not null  references Tracks(Id), 
    constraint pk3 primary key (Compilation_id,Tracks_id));

SELECT * FROM Tracks;
SELECT * FROM Genre;
SELECT * FROM Performers;
SELECT * FROM Genre_Performers;
SELECT * FROM Performers_Albums;
SELECT * FROM  Albums;
SELECT * FROM Compilation;
SELECT * FROM Compilation_Tracks;

