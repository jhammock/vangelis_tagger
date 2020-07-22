------------------------------------------------------------------------------------------------------- compile
compiling:
$ sudo g++ -o environments_tagger environments_tagger.cxx

compile using makefile instead
$ make -f makefile
------------------------------------------------------------------------------------------------------- run
run inside the folder /eol_tagger/ 

./environments_tagger ../test_text_data/
-------------------------------------------------------------------------------------------------------
Installing libboost in Rhel

https://serverfault.com/questions/445904/how-to-install-libboost-devel-on-centos-6-3
https://stackoverflow.com/questions/44157279/how-to-install-boost-library-on-centos-7-3-64bit
or maybe:
https://stackoverflow.com/questions/1101577/install-and-build-boost-library-in-linux/1102076
------------------------------------------------------------------------------------------------------- write output to file
https://askubuntu.com/questions/420981/how-do-i-save-terminal-output-to-a-file
./environments_tagger ../test_text_data/ &> output.txt
-------------------------------------------------------------------------------------------------------
From Vangelis:
1. The server in HCMR is running Debian 4.9 and the following lib boost::regex libraries have been installed
libboost-regex-dev
libboost-regex1.62-dev
libboost-regex1.62.0

From reading:
yum install boost-devel

From other reading:
Usually on centos 7, I do
yum update
yum install epel-release
and then
yum install boost boost-thread boost-devel

Eli only used: worked OK!
yum install boost-devel
Then I re-compile by:
$ make -f makefile

-------------------------------------------------------------------------------------------------------
