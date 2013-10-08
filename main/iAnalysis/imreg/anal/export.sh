#~/bin/bash

# Makes an SVN-free version of this in ~/src, and checks it into svn repo
#  of svoboda lab.
if [ -d ~/src ];
then
  # create
  rm -rf ~/src/sci
	mkdir ~/src/sci
	cp -r ../anal ~/src/sci
	rm -rf ~/src/sci/.svn
	rm -rf ~/src/sci/*/.svn
	rm -rf ~/src/sci/*/*/.svn
	rm -rf ~/src/sci/*/*/*/.svn
	rm -rf ~/src/sci/*/*/*/*/.svn
	rm -rf ~/src/sci/*~
	rm -rf ~/src/sci/*/*~
	rm -rf ~/src/sci/*/*/*~
	rm -rf ~/src/sci/*/*/*/*~
	rm -rf ~/src/sci/*/*/*/*/*~
	rm ~/src/sci/anal/tmp/*

	# checkout current repoa
	rm -rf ~/src/svorepo
	svn co https://svn.janelia.org/svobodalab/software/labshare/trunk ~/src/svorepo
	cp -r ~/src/sci/anal ~/src/svorepo/+people/+spp/sci
	svn add ~/src/svorepo/+people/+spp/sci/anal/*m
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*m
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*/*m
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*/*/*m
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*/*/*/*m
	svn add ~/src/svorepo/+people/+spp/sci/anal/*sh
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*sh
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*/*sh
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*/*/*sh
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*/*/*/*sh
	svn add ~/src/svorepo/+people/+spp/sci/anal/*py
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*py
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*/*py
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*/*/*py
	svn add ~/src/svorepo/+people/+spp/sci/anal/*/*/*/*/*py

	svn commit ~/src/svorepo


else
  echo '~/src does not exist.  Create it.'
fi
