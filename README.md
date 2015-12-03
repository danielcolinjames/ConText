# TextViz
This application was created with Processing and visually and tonally represents my SMS logs from the past few months.

I left out the file SMS2.csv because it contains my SMS history which I would rather not make public.

If you'd like to test this code out yourself and you have an Android phone, download the app "SMS Backup & Restore"
from the Play Store and save your texts to an XML file. Then open the XML file in Excel, and it should give you some sort
of warning message. One of the options leads to a spreadsheet with a long column down the middle containing messages in
groups of 5 categories. Every 1 out of 5 rows will say either "Sent" or "Received", every 2nd row will tell you the contact's phone
number, every 3rd row will tell you the contact's name, every 4th row will contain the date and time that the message was sent, and every 5th row will contain the content of the message.

Carriage returns in message contents will break the code, so they need to be removed from the spreadsheet before it
is read into Processing.

Once everything is in the right format, save the file as a .csv and make sure it's in the /data folder of the Processing sketch and that you change the pathname in the code to match the name of the .csv file you create.

A demo of the project can be seen here: https://www.youtube.com/watch?v=RK5N7gNVDnQ.


--------------------------------------------------------------------------------------------------------------------------------------

Artist statement:

I’ve often thought about the intricacies inherent in textual communication and how easily meaning can be lost. Nonverbal cues and subtleties comprise a large and important component of communication. These subtleties most often come in tonal and visual forms. When everything but the literal content of a message is stripped away, it can become difficult to understand or easy to misinterpret.

For this project, I took all of the text messages sent from and received by my phone over the last few months and represented them in such a way that we see the opposite: a solely visual and tonal expression of their contents. Every text message creates a visual based on a number of factors: the frequency of each letter, the length of the message, the time of day it was sent, whether it was sent or received, and the name of the recipient or sender.

For each message, the background of the visual is coloured according to the way that the sky usually looks at the time of day it was sent. The first and last initials of the sender or recipient determine the tint colour that is used throughout the piece. This tint is used to colour two things: the frame around the visual, and the dynamic shapes that represent the frequency of letters used in each message. A tone is then generated for each message based on its most frequently used letter. Finally, after visually and tonally representing each message, there is a brief delay equal in milliseconds to its length in characters.

If you watch closely as the generated imagery flickers, some trends reveal themselves, but they are difficult to pin down with any certainty. When the content of a message is obfuscated by tonal and visual elements, we must simply guess at its original meaning. This creates an interesting contrast to the original problem, wherein we know what the message means through its content but have no visual or auditory cues: now we have visual and audio cues but no context for them.

With this piece I hoped to make the audience think about the multitude of ways that we connect with one another and consider the subtle differences between them.

