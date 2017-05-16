# Data-Free-Server

Main.rb is a server-side script that recieves incoming texts, runs Ruby bots to find requested contest, and sends that information back to the user. Once an answer is found, it encodes it into a compressed character format.

The server utilizes:
 - Twilio for sms functionality
 - Ngrok as a local host
 - Sinatra as a web hook
