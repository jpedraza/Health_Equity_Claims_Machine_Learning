import csv as csv
import os.path
import json

configFile = "config.json"
def readConfigFile():
	with open(configFile) as configFileStream:
		return json.load(configFileStream)

def createCsvFromMarkovDict(markovDict, columnNames, fileName):
	open_file_object = csv.writer(open(fileName, "wb"))

	open_file_object.writerow(columnNames)

	for key in markovDict:
		for subkey in markovDict[key]:
			open_file_object.writerow([key, subkey, markovDict[key][subkey]])

def createMarkovDictFromCsv(fileName):
	csv_file_object = csv.reader(open(fileName, 'rb'))
	header = csv_file_object.next()

	markovDict = {}

	for row in csv_file_object:
		key = row[0]
		subkey = row[1]
		probability = float(row[2])

		if markovDict.has_key(key):
			markovDict[key][subkey] = probability
		else:
			markovDict[key] = { subkey: probability }

	return markovDict