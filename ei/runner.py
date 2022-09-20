import requests
import json
import datetime
import time
import csv

line_left = "583e3f17-56de-4926-ab74-22fc4eb6afe8" # line_left
line_right = "6841ecc6-ccdd-4988-b913-159aab85ab28" # line_right
sample_interval = 60  # seconds
recording_count = 1

save_data_files = True
upload_data_files = False
inference_on = False
fieldnames = ['timestamp', 'journey_dur', 'hod']
final = []

def get_traffic(total_cars):

    #
    #
    #

    if total_cars < 6:
        return "light"
    if total_cars < 13:
        return "moderate"
    else:
        return "heavy"

def get_last_recording():

    #
    # return id of last recording
    #
    r = requests.get("http://opendatacam:8080/recordings?limit=1")
    recording_id = 0
    recordings = r.json()
    for recording in recordings['recordings']:
        recording_id = recording['_id']

    print("Last recording is: {}.".format(recording_id))
    return recording_id

def save_rec_data(recording_id):

    #
    # saves (overwrites) recording data in features.txt
    #
    cars = []
    #journey = {"id": 0, "left_time": "2022-09-14T22:59:07.479Z", "right_time": "2022-09-14T22:59:07.479Z"}
    car_count = 0
    total_car_count = 0

    r = requests.get("http://opendatacam:8080/recording/" + recording_id + "/counter")
    rec_counter = r.json()
    updated = False
    rec_date = datetime.datetime.strptime(rec_counter['dateStart'], '%Y-%m-%dT%H:%M:%S.%fZ')
    # for each counted item...
    for h in rec_counter['counterHistory']:
        if h['name'] == "car":
            # loop through our list to see if car exists
            car_count = 0
            for car in cars:
                updated = False
                if car["id"] == h["id"]:
                    # car is already in list, so update
                    updated = True
                    if h['area'] == line_left:
                        cars[car_count]['left_time'] = h['timestamp']
                        #cars[car_count]['right_time'] = "0:00"
                    else:
                        #cars[car_count]['left_time'] = "0:00"
                        cars[car_count]['right_time'] = h['timestamp']
                car_count = car_count + 1

            if not updated:
                # car does not exist, append it
                if h['area'] == line_left:
                    cars.append({'id': h['id'], 'left_time': h['timestamp'], 'right_time': "0:00"})
                else:
                    cars.append({'id': h['id'], 'left_time': "0:00", 'right_time': h['timestamp']})
                # update newly added car with any sensor/constant data here
                

    # Now we have a list of dicts
    # calculate journey time for cars that have crossed both lines
    #print(cars)

    car_count = 0
    for car in cars:
        if car['left_time'] != "0:00" and car['right_time'] != "0:00":
            car_count = car_count + 1
            left_time = datetime.datetime.strptime(car['left_time'], '%Y-%m-%dT%H:%M:%S.%fZ')
            right_time = datetime.datetime.strptime(car['right_time'], '%Y-%m-%dT%H:%M:%S.%fZ')
            diff = left_time - right_time
            elapsed = diff.total_seconds() * 1000  # milliseconds
            #print("here 2")
            ts_diff = right_time - rec_date
            timestamp = ts_diff.total_seconds() * 1000
            car.update({'timestamp': timestamp})
            car.update({'duration': elapsed})
            car.update({'hod': left_time.hour})  # hour of day
        else:
            #cars.remove(car)
            car.update({'duration': 0})
    total_car_count = car_count

    #print("--  ")
    #print(cars)
    final = []
    # For cars where duration > 0, save data
    car_count = 0
    for car in cars:
        if car['duration'] != 0:
            car_count = car_count + 1
            #print("here 3")
            final.append({'timestamp': int(car['timestamp']), 'journey_dur': int(car['duration']), 'hod': car['hod']} )
            #f.write(str(car['timestamp']) + "," + str(car['duration']) + "," + str(car['hod']))
    if save_data_files:
        nf = "{:02d}{:02d}{:02d}{:02d}{:02d}".format(rec_date.month, rec_date.day, rec_date.hour, rec_date.minute, rec_date.second)
        fname = get_traffic(total_car_count) + ".sample" + nf + ".csv"
        with open(fname, "w", encoding="UTF8", newline="") as csvf:
            writer = csv.DictWriter(csvf, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(final)
        if car_count == 0:
            print("no cars to save!")
            # empty the features file
            f = open("features.txt", "w")
            f.write("")
            f.close()
        else:
            # overwite the features file
            with open("test/" + fname + ".csv", "w", encoding="UTF8", newline="") as csvf:
                writer = csv.DictWriter(csvf, fieldnames=fieldnames)
                writer.writeheader()
                writer.writerows(final)
    #print(cars)
    print("Found {} car journey(s).".format(car_count))
    print("Saved to file: {}".format(fname))
    print(final)

# Start here

while True:
    print("-----------------------------------------------")
    r = requests.get("http://opendatacam:8080/recording/start")
    print("Started recording {} for next {} second(s)...".format(recording_count, sample_interval))
    print("Response from odc: {}".format(r.text))
    started = datetime.datetime.now()
    started_formatted = "{:02d}{:02d}{:02d}{:02d}{:02d}".format(started.month, started.day, started.hour, started.minute, started.second)
    print("Started recording file: {}.".format(started_formatted))
    time.sleep(sample_interval)
    print("Stopping recording...")
    r = requests.get("http://opendatacam:8080/recording/stop")
    rr = get_last_recording()
    save_rec_data(rr)
    recording_count = recording_count + 1
