import sqlalchemy
from pprint import pprint 


engine = sqlalchemy.create_engine('postgresql://')
connection = engine.connect()  

genre_performers = connection.execute(f"""
SELECT g.name, count(p.Nickname) FROM Genre g
JOIN Genre_Performers gp ON g.Id = gp.Genre_id
JOIN Performers p ON gp.Performers_id = p.id
GROUP BY g.name;
""").fetchall()
print()
for i in genre_performers:
    print(f'1.В жанре "{i[0]}" - {i[1]} исполнитель(ей)')
print()

track_album = connection.execute(f"""
SELECT COUNT(t.name) FROM Tracks t
JOIN Albums a ON t.Albums_id = a.id
WHERE Release BETWEEN 2019 AND 2020;
""").fetchall()
print(f'Количество треков, вошедших в альбомы 2019-2020 годов - {track_album[0][0]} трека(ов)')
print()

avg_duration = connection.execute(f"""
SELECT a.Name, ROUND(AVG(t.Duration),2)  FROM Tracks t
JOIN Albums a ON t.Albums_id = a.id
GROUP BY  a.id;
 """).fetchall()
for i in avg_duration:
    print(f' В альбоме "{i[0]}" средняя продолжительность треков {i[1]} минут')
print()

avg_duration = connection.execute(f"""
SELECT DISTINCT p.nickname FROM performers p
WHERE p.nickname NOT IN (
SELECT DISTINCT p.nickname FROM performers p
LEFT JOIN performers_albums pa ON p.id = pa.performers_id
LEFT JOIN albums a ON a.id = pa.albums_id
WHERE a.release = 2020)
ORDER BY p.nickname;
 """).fetchall()
print(f" Исполнители, которые не выпустили альбомы в 2020 году: ")
for i in avg_duration:
    print(f'"{i[0]}"')
print()

performer = 'Король и шут'
compilat_perform = connection.execute(f"""
SELECT c.name  FROM compilation c
JOIN compilation_tracks ct ON c.id = ct.compilation_id
JOIN tracks t ON ct.tracks_id = t.id
JOIN albums a ON t.albums_id = a.id
JOIN performers_albums pa ON a.id = pa.albums_id
JOIN performers p ON p.id = pa.performers_id
WHERE p.nickname = '{performer}';
 """).fetchall()
print(f"Названия сборников, в которых присутствует исполнитель '{performer}':")
for i in compilat_perform:
    print(f'"{i[0]}"')
print()

compilat_perform = connection.execute(f"""
SELECT a.name FROM albums a
JOIN performers_albums pa ON a.id = pa.albums_id
JOIN performers p ON pa.performers_id = p.id  
JOIN genre_performers gp ON p.id = gp.performers_id
JOIN genre g ON g.id = gp.genre_id
GROUP BY a.name
HAVING COUNT(g.name) >1;
 """).fetchall()
print(f'название альбомов, в которых присутствуют исполнители более 1 жанра:')
for i in compilat_perform:
    print(f'"{i[0]}"')
print()

track_not_compilat = connection.execute(f"""
SELECT t.name FROM tracks t
LEFT JOIN compilation_tracks ct ON t.id = ct.tracks_id
WHERE ct.tracks_id IS NULL;
 """).fetchall()
print(f'Название треков, которые не входят в сборники:')
for i in track_not_compilat:
    print(f'"{i[0]}"')
print()

perf_short_track = connection.execute(f"""
SELECT p.nickname FROM performers p
JOIN performers_albums pa ON p.id = pa.performers_id
JOIN albums a ON a.id = pa.albums_id
JOIN tracks t ON a.id = t.albums_id
WHERE duration = (SELECT MIN(duration) FROM Tracks);
""").fetchall()
print(f'Исполнитель(и), написавший(е) самый короткий по продолжительности трек: ')
for i in perf_short_track:
    print(f'"{i[0]}"')
print()

alb_min_treck = connection.execute(f"""
SELECT a.name FROM albums a
JOIN tracks t ON a.id = t.albums_id
GROUP BY a.name
HAVING count(a.name) = (SELECT count(name) FROM Tracks 
GROUP BY  Albums_id
ORDER BY count(name)
LIMIT 1);
 """).fetchall()
print(f'Названия альбома(ов), содержащего(их) наименьшее количество треков: ')
for i in alb_min_treck:
    print(f'"{i[0]}"')
