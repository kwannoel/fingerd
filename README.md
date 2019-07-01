# fingerd

Finger Daemons

Figuring out:
- how to contact others on the same network.
- online/offline status at a given time
- sharing of basic contact details

finger was used to deliver .plan / .project files as a sort of pre-Twitter/Tumblr microblog

example of a working finger daemon:
```
$ finger callen@localhost
Login: callen            Name: callen
Directory: /home/callen  Shell: /bin/zsh
```

How it works:
- Uses TCP protocol, however it is not a web server
- Client requests some info
- TCP transmit to server
- TCP sends to client

Running the debug environment:
```
> stack build
> sudo stack exec which debug
```
Open a new terminal
```
> telnet localhost 79
> blah
```
Should receive the following responses:
client:
```
blah
blah
Connection closed by foreign host.
```
server:
```
"blah\r\n"
```

with finger:
client:
```
finger noel@localhost
noel
```
server:
```
"noel\r\n"
```
