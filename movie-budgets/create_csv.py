import pandas as pd
from urls_to_scrape import urls_n_filenames
import json
import gzip

df = pd.DataFrame()

num_movies = 0

for u_n_f in urls_n_filenames:
    # load json file in
    print(f'Opening ./data/{u_n_f[1]}.json')

    with gzip.GzipFile(f'./data/{u_n_f[1]}.json', 'r') as fin:
        
        print(f'Pushing {u_n_f[1]} to csv')
        data = json.loads(fin.read().decode('utf-8'))

        # loop through json and append each movie into a dataframe
        for movie_hash in data:
            # `[[*data[movie_hash]]]` ensures correct column ordering
            df = df.append(data[movie_hash], ignore_index=True)[[*data[movie_hash]]]

            # for logging progress
            num_movies += 1
    

        print(f'Done pushing {u_n_f[1]} to csv. {num_movies} movies appended to csv.')

print(df.shape)

# save output to a csv
df.to_csv('movie-budgets.csv')