#Import all the needed Python Libraries


import pandas as pd
import os
import numpy as np

from flask import Flask, jsonify, render_template

from collections import OrderedDict
import datetime
import time

#The requests library allows communication to the api and the getting of data
import requests

#This library converts latitude/longtitude to a country
from country_bounding_boxes import (
      country_subunits_containing_point,
      country_subunits_by_iso_code
    )

##########################################################################
#
#        Functions
#
#########################################################################

def find_country(longitude, latitude):
    country='NOCOUNTRY'
    for c in country_subunits_containing_point(lon=longitude,lat=latitude):
        country = c.name
    return country

def calculate_country(row):
    return find_country(row['longitude'], row['latitude'])

def find_continent(longitude, latitude):
    continent = 'NOCONTINENT'
    for c in country_subunits_containing_point(lon=longitude,lat=latitude):
        continent = c.continent
    return continent

def calculate_continent(row):
    return find_continent(row['longitude'], row['latitude'])


########################################################################


#Gather Data
#Set up the urls to access the api
root_url = "https://opensky-network.org/api"
all_state_vectors = "/states/all"

#Get all state vectors
url = root_url + all_state_vectors
response = requests.get(url, verify=True)

#Move the JSON state information into a variable.  The JSON has a dictionary with the 'states' as the  key
# and a list of lists as the value.  Each track is a list.
data = response.json()

#Now begin to move the data into pandas dataframes
#Set up the labels for the dataframe
labels=['icao24','callsign','origin_country','time_position','last_contact','longitude','latitude',
        'geo_altitude','on_ground','velocity','true_track','vertical_rate','sensors','baro_altitude',
        'squawk','spi','position_source']

#Here's the list of lists containing all the state vectors for each flight
x=data['states']

#x is the list of all the vectors for a particular time that was in the JSON data
#Now create a dataframe with all the vectors as rows
df = pd.DataFrame.from_records(x, columns=labels)

#Filter the dataframe to only the data we need
relevant_df=df.drop(columns=['time_position', 'last_contact', 'true_track','on_ground','vertical_rate', 'sensors', 'baro_altitude',
                                       'squawk', 'spi','position_source'])


#Clean up the data by dropping records with NaN
clean_df = relevant_df.dropna()

flight_df = clean_df #Use this data frame to store all the flight information

drop_down_list_df = flight_df['icao24'].tolist()


#County flights by continent
clean_df['continent'] = clean_df.apply(calculate_continent, axis=1)
continent_counts = clean_df['continent'].value_counts()
continent_counts_dict= continent_counts.to_dict()

#Count flights by country of origin
count_list_of_origin_countries = clean_df['origin_country'].value_counts()
count_list_of_origin_countries_dict = count_list_of_origin_countries.to_dict()


#Country Counts
#Determine what country every flight is located
#Add a column to the dataframe with the country for each flight
clean_df['country'] = clean_df.apply(calculate_country, axis=1)

#country_counts is a panda series with all the country counts.
country_counts = clean_df['country'].value_counts()
total_flights = country_counts.sum()

#Find the Top Ten Countries
largest_country_counts = country_counts.nlargest(10)
sum_of_largest_10 = largest_country_counts.sum()
all_others = total_flights - sum_of_largest_10
largest_country_counts_dict= largest_country_counts.to_dict()
largest_country_counts_dict['All Others'] = int(all_others)
print("Largest country flight counts")
print(largest_country_counts_dict)

#Find the top ten country of origins
origin_counts = clean_df['origin_country'].value_counts()
total_origin_flights = origin_counts.sum()
largest_origin_counts = origin_counts.nlargest(10)
sum_of_largest_10_origins = largest_origin_counts.sum()
all_others_origins = total_origin_flights - sum_of_largest_10_origins
largest_origin_counts_dict= largest_origin_counts.to_dict()
largest_origin_counts_dict['All Others'] = int(all_others_origins)
print("Largest country origin counts")
print(largest_origin_counts_dict)



count_list_of_origin_countries = clean_df['origin_country'].value_counts()
count_list_of_origin_countries_dict = count_list_of_origin_countries.to_dict()

#Prepare for geojson

def df_to_geojson(df, properties, lat='latitude', lon='longitude'):
    geojson = {'type':'FeatureCollection', 'features':[]}
    for _, row in df.iterrows():
        feature = {'type':'Feature',
                   'properties':{},
                   'geometry':{'type':'Point',
                               'coordinates':[]}}
        feature['geometry']['coordinates'] = [row[lon],row[lat]]
        for prop in properties:
            feature['properties'][prop] = row[prop]
        geojson['features'].append(feature)
    return geojson

cols = ['icao24', 'callsign']
geojson = df_to_geojson(clean_df, cols)




#Airport arrivals----------------------------->
departures_by_airport = "/flights/arrival?airport="

#Set Up the query
arrival_airport_code = "EDDF"
end_dt=int(datetime.datetime(2018,6,28,12,0).timestamp())
start_dt=int(datetime.datetime(2018,6,26,12,0).timestamp())
time_interval= "&begin="+str(start_dt)+"&end="+str(end_dt)
url = root_url + departures_by_airport + arrival_airport_code + time_interval

#Make the api call
response = requests.get(url, verify=True)
data = response.json()

#Now begin to move the data into pandas dataframes
#Set up the labels for the dataframe
labels=['arrivalAirportCandidatesCount','callsign','departureAirportCandidatesCount','estArrivalAirport',
        'estArrivalAirportHorizDistance','estArrivalAirportVertDistance','estDepartureAirport',
        'estDepartureAirportHorizDistance','estDepartureAirportVertDistance','firstSeen','icao24','lastSeen']

df = pd.DataFrame.from_records(data, columns=labels)
#Filter the dataframe to only the data we need
relevant_df=df.drop(columns=['arrivalAirportCandidatesCount', 'departureAirportCandidatesCount',
                             'estArrivalAirportHorizDistance',
                             'estArrivalAirportVertDistance','estDepartureAirportHorizDistance',
                             'estDepartureAirportVertDistance',
                             'firstSeen','lastSeen'])
arrivals_json = relevant_df.to_json(orient='index')
#-----------------------------------------------------
#



# create instance of Flask app
app = Flask(__name__)



@app.route("/")
def index():
    return render_template('index.html')

@app.route("/names")
def sample_names():
    return jsonify(drop_down_list_df)

############################
# Flasks called by JavaScript
# 
     
@app.route('/metadata/<sample>')
def sample_meta_data_f(sample):
    print ('In metadata. The sample requested is:')
    print(sample)

    flight_id = sample

    x = flight_df.loc[flight_df['icao24'] == flight_id]

    print('The flight returned is:')
    print(x)

    sample_dic = {}

    sample_dic['icao24'] = (x.iloc[0]['icao24'])
    sample_dic['callsign'] = x.iloc[0]['callsign']
    sample_dic['origin_country'] = x.iloc[0]['origin_country']
    sample_dic['longitude'] = str(x.iloc[0]['longitude'])
    sample_dic['latitude'] = str(x.iloc[0]['latitude'])
    sample_dic['geo_altitude'] = str(x.iloc[0]['geo_altitude'])
    sample_dic['velocity'] = str(x.iloc[0]['velocity'])

    print('This will be jsonified')
    print(sample_dic)
    print('############################')

    return jsonify(sample_dic)

@app.route("/flights")
def flight_names():
    return jsonify(largest_country_counts_dict)

@app.route("/continents")
def continent_names():
    return jsonify(continent_counts_dict)

@app.route("/ownership")
def country_names():
    return jsonify(largest_origin_counts_dict)

@app.route("/locations")
def location_names():
    return jsonify(geojson)
###############################################
#OLD Code was removed from here.

##############################################


#Start Execution

if __name__ == "__main__":
    app.run(debug=True)