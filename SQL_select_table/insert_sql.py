import csv
import sqlalchemy
import glob
from tqdm import tqdm
import time

files_list = []
for i in glob.glob('*.csv'):
    files_list.append(i)   
  
dict = {}
try:
    for file in tqdm(files_list, ncols = 50):
        time.sleep(0.1)
        with open ((str(file)),  encoding = "UTF-8") as f:
            reader = csv.DictReader(f)
            name = ((str(file)).split('.'))[1]                   
            for item in  reader:            
                index = 1            
                data = item[list(item.keys())[0]].split(";")                
                engine = sqlalchemy.create_engine('postgresql://............')
                connection = engine.connect()            
                if name == "Genre":                                              
                    dict["Genre"]= f"DEFAULT, '{data[index]}'"
                elif name == "Performers":    
                    dict["Performers"]= f"DEFAULT, '{data[index]}'" 
                elif name == "Performers":    
                    dict["Performers"]= f"DEFAULT, '{data[index]}'"         
                elif name == "Albums":
                    dict["Albums"]= f"DEFAULT, '{data[index]}',{data[index+1]}"   
                elif name == "Compilation":
                    dict["Compilation"]= f"DEFAULT, '{data[index]}',{data[index+1]}"
                elif name == "Tracks":
                    dict["Tracks"]= f"DEFAULT, '{data[index]}',{data[index+1]},{data[index+2]}"
                elif name == "Genre_Performers":
                    dict["Genre_Performers"]= f"DEFAULT, {data[index]},{data[index+1]}"
                elif name == "Performers_Albums":
                    dict["Performers_Albums"]= f"DEFAULT, {data[index]},{data[index+1]}"
                elif name == "Compilation_Tracks":                             
                    dict["Compilation_Tracks"]= f"DEFAULT, {data[index]},{data[index+1]}"                    
                connection.execute(f"""
                INSERT INTO {name}
                VALUES({dict[name]});
                """)
    print("Данные загружены.")
except:
    print("Повторяющееся значение ключа нарушает ограничение уникальности")