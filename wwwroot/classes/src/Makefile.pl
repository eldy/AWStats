#!/usr/bin/perl


$FILENAME=awgraphapplet;

print "Build class file by compiling .java file\n";
$ret=`javac AWGraphApplet.java`;
print $ret;

print "Build jar file\n";
$ret=`jar cvf ../$FILENAME.jar AWGraphApplet.class`;
print $ret;

