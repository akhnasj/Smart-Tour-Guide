import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore

# Step 1: Initialize Firebase Admin SDK
cred = credentials.Certificate(r"C:\Users\AKHNA\Downloads\smart-tour-guide-3d30d-firebase-adminsdk-h17r2-bda949eabd.json")  # Update with your JSON file path
firebase_admin.initialize_app(cred)

# Step 2: Initialize Firestore
db = firestore.client()

# Step 3: Read the CSV file
df = pd.read_csv(r"C:\Users\AKHNA\Desktop\MCA\Smart-Tour-Guide\locations.csv")  # Update with your CSV file path

# Step 4: Upload data to Firestore
for index, row in df.iterrows():
    # Convert the row to a dictionary
    data = row.to_dict()
    
    # Add the document to the 'locations' collection
    # Use the location name or another unique identifier as the document ID
    location_id = str(data.get('l_id', index))  # Use 'l_id' or index as the document ID
    db.collection('locations').document(location_id).set(data)

print("Locations uploaded successfully!")