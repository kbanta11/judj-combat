import firebase_admin
from firebase_admin import credentials, firestore
import datetime
import pytz
import sys
import pandas as pd
import numpy as np

cred = credentials.Certificate('judj-combat-firebase-adminsdk-a7nk9-ea41a97dc0.json')
app = firebase_admin.initialize_app(cred)
db = firestore.client()

def process_csv(filepath):
    batch = db.batch()
    with open(filepath, newline = '') as file:
        df = pd.read_csv(file, delimiter=',')
        df['date'] = pd.to_datetime(df['date'])
        df['date'] = df['date'].apply(lambda x: x.replace(tzinfo=pytz.timezone('America/Los_Angeles')))
        df = df.replace(np.nan, '', regex=True)
        event_keys = {}
        print(df.head());
        for i, row in df.iterrows():
            event_key = '{}-{}-{}'.format(row['name'], row['date'],row['promoter'])
            print(event_key)
            if event_key in event_keys:
                event_ref_id = event_keys[event_key]
                fight_ref = db.collection('fights').document()
                fight_event_ref = db.collection('events').document(event_ref_id).collection('fights').document(fight_ref.id)
                fight_data = {
                    'fight_id': fight_ref.id,
                    'event_id': event_ref_id,
                    'card_rank': row['card_rank'],
                    'weightclass': row['weightclass'],
                    'weight': row['weight'],
                    'num_rounds': row['num_rounds'],
                    'type': row['type'],
                    'red_fighter': {
                        'first_name': row['red_fname'],
                        'last_name': row['red_lname'],
                        'nickname': row['red_nickname'],
                        'wins': row['red_wins'],
                        'losses': row['red_losses'],
                        'draws': row['red_draws'],
                        'no_contests': row['red_no_contest'],
                        'ranking': row['red_ranking'],
                    },
                    'blue_fighter': {
                        'first_name': row['blue_fname'],
                        'last_name': row['blue_lname'],
                        'nickname': row['blue_nickname'],
                        'wins': row['blue_wins'],
                        'losses': row['blue_losses'],
                        'draws': row['blue_draws'],
                        'no_contests': row['blue_no_contest'],
                        'ranking': row['blue_ranking'],
                    }
                }
                batch.set(fight_ref, fight_data)
                batch.set(fight_event_ref, fight_data)
            else:
                event_ref = db.collection('events').document()
                event_keys[event_key] = event_ref.id
                event_data = {
                    'event_key': event_key,
                    'name': row['name'],
                    'tagline': row['tagline'],
                    'date': row['date'],
                    'location': row['location'],
                    'promoter': row['promoter'],
                    'event_id': event_ref.id,
                }
                batch.set(event_ref, event_data)
                fight_ref = db.collection('fights').document()
                fight_event_ref = event_ref.collection('fights').document(fight_ref.id)
                fight_data = {
                    'fight_id': fight_ref.id,
                    'event_id': event_ref.id,
                    'card_rank': row['card_rank'],
                    'weightclass': row['weightclass'],
                    'weight': row['weight'],
                    'num_rounds': row['num_rounds'],
                    'type': row['type'],
                    'red_fighter': {
                        'first_name': row['red_fname'],
                        'last_name': row['red_lname'],
                        'nickname': row['red_nickname'],
                        'wins': row['red_wins'],
                        'losses': row['red_losses'],
                        'draws': row['red_draws'],
                        'no_contests': row['red_no_contest'],
                        'ranking': row['red_ranking'],
                    },
                    'blue_fighter': {
                        'first_name': row['blue_fname'],
                        'last_name': row['blue_lname'],
                        'nickname': row['blue_nickname'],
                        'wins': row['blue_wins'],
                        'losses': row['blue_losses'],
                        'draws': row['blue_draws'],
                        'no_contests': row['blue_no_contest'],
                        'ranking': row['blue_ranking'],
                    }
                }
                batch.set(fight_ref, fight_data)
                batch.set(fight_event_ref, fight_data)
                
    batch.commit()   
if __name__ == '__main__':
    process_csv((sys.argv[1]))