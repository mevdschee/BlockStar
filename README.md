BlockStar
=========

Puzzle game build in Flex 4

Demo: http://www.maurits.vdschee.nl/blockstar/

## Requirements

- Apache Flex® SDK 4.9
- Flash Player 11 (content debugger)
- Java 1.6

## Installation

### Linux (Debian based)

Download Apache Flex® SDK 4.9 binaries from (Mac version works for Linux):

http://flex.apache.org/download.html

Unpack "apache-flex-sdk-4.9.0-bin.tar.gz" and place it in a directory named "sdk".

Download the and "Projector content debugger" and "playerglobal.swc" from:

http://www.adobe.com/support/flashplayer/downloads.html

Unpack "flashplayer_11_sa_debug.i386.tar.gz" and move flashplayerdebugger to "bin/flashplayerdebugger".
Move "playerglobal11_5.swc" to "frameworks/libs/player/11.1/playerglobal.swc".

In the file "frameworks/flex-config.xml" replace "{playerglobalHome}" by "libs/player".

Make sure you have 32-bit compatibility libraries installed by running:

    sudo apt-get install ia32-libs
