# TextViz
This application was created with Processing and visually represents my SMS logs from the past few months.


I left out the file SMS2.csv because it contains my SMS history which I would rather not make public.

If you'd like to test this code out yourself and you have an Android phone, download the app "SMS Backup & Restore"
from the Play Store and save your texts to an XML file. Then open the XML file in Excel, and it should give you some sort
of warning message. One of the options leads to a spreadsheet with a long column down the middle containing messages in
groups of 5 categories. Every 1/5 row will say either "Sent" or "Received", every 2nd row will tell you the contact's phone
number, every 3rd row will tell you the contact's name, every 4th row will contain a timestamp, and every 5th row will contain
the message's contents.

Carriage returns in message contents will break the code, so they need to be removed from the spreadsheet before the spreadsheet
is read into Processing.

Once everything is in the right format, save the file as a .csv and make sure it's in the /data folder of the Processing sketch.
