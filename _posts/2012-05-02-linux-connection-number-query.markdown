---
layout: post
title: "linux connection number query"
date: 2012-05-02 07:25
comments: true
category: linux
tags: ['linux']
---

``` bash
$netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}' ;netstat -nat |wc -l
#得到类似如下的输出：
LAST_ACK 5
SYN_RECV 28
CLOSE_WAIT 475
ESTABLISHED 646
FIN_WAIT1 35
FIN_WAIT2 111
CLOSING 28
TIME_WAIT 1448
2849
```
最后一行是总的连接数。前面那些，左列是连接状态，右列是数量。
 
连接状态`man netstat`说明：

```
ESTABLISHED
The socket has an established connection.
 
SYN_SENT
The socket is actively attempting to establish a connection.
 
SYN_RECV
A connection request has been received from the network.
 
FIN_WAIT1
The socket is closed, and the connection is shutting down.
 
FIN_WAIT2
Connection is closed, and the socket is waiting for a shutdown from the remote end.
 
TIME_WAIT
The socket is waiting after close to handle packets still in the network.
 
CLOSED The socket is not being used.
 
CLOSE_WAIT
The remote end has shut down, waiting for the socket to close.
 
LAST_ACK
The remote end has shut down, and the socket is closed. Waiting for acknowledgement.
 
LISTEN The  socket  is  listening for incoming connections.  Such sockets are not included in the output unless you
specify the –listening (-l) or –all (-a) option.
 
CLOSING
Both sockets are shut down but we still don’t have all our data sent.
 
UNKNOWN
The state of the socket is unknown.
```