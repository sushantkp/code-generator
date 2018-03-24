#! /bin/sh
diskutil erasevolume HFS+ "mtmpdir" `hdiutil attach -nomount ram://131072`
