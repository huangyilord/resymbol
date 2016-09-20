#!/bin/sh

CONFIG_FILE_NAME=resymbol.conf
BIN_DIR=bin
SRC_DIR=origin
DST_DIR=output
WORK_DIR=temp

ARCHITECTURE_FAMILIES="i386 x86_64 arm64 armv7"

SRC_FILES=`ls $SRC_DIR/*.a`

## prepare
rm -rf $WORK_DIR
mkdir $WORK_DIR

echo detect files: $SRC_FILES
for file in $SRC_FILES
do
	echo processing $file ...
	fileName=`basename $file`
	TEMP_FILES=""

	## extract architectures
	for arch in $ARCHITECTURE_FAMILIES
	do
		targetName=$WORK_DIR/$fileName-$arch.a
		rm -f $targetName
		lipo -thin $arch -output $targetName $file
		TEMP_FILES="$TEMP_FILES $targetName"
	done
	echo extract files: $TEMP_FILES

	## extract objs
	for tempFile in $TEMP_FILES
	do
        tempFileName=`basename $tempFile`
        objDir=$tempFile-objs
        rm -rf $objDir
        mkdir $objDir
        cd $objDir
        ar -x ../$tempFileName
        OBJ_FILES=`ls *.o`

		## rename
        for obj in $OBJ_FILES
        do
            ../../$BIN_DIR/resymbol $obj ../../$CONFIG_FILE_NAME
            renameObj=$obj.r
            if [ -f "$renameObj" ]
            then
                rm $obj
                mv $renameObj $obj
                ar -r ../../$tempFile $obj
            fi
        done
		cd ../..
	done

	## create package
	lipo -create -o $DST_DIR/$fileName $TEMP_FILES
done

## clean up
rm -rf $WORK_DIR

