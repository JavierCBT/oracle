#!/bin/ksh
ORACLE_USER="oracle"
SCRIPT_NAME=${0##*/}
CATALOG="rcat/rcat2019@CATALOG"

CUSER=`id |cut -d"(" -f2 | cut -d ")" -f1`
if [ "$CUSER" == "root" ];then
  echo "I am root, now I am \"${ORACLE_USER}\""
  cd `dirname $0`
  SCRIPTPATH=`pwd`
  cd $OLDPWD
  su - ${ORACLE_USER} -c "${SCRIPTPATH}/${SCRIPT_NAME}"
  retcode=$?
  echo "I am root again... exiting with code $retcode"
  exit $retcode
fi

SCRIPT_NAME=${SCRIPT_NAME%.*}
ORACLE_SID=${SCRIPT_NAME%%.*}

#. /users/oinstall/oracle/$ORACLE_SID.sh
#SID=$(echo $ORACLE_SID | sed 's/...$//')

TDPO_OPTFILE="/opt/tivoli/tsm/client/oracle/bin64/${ORACLE_SID}/tdpo_${ORACLE_SID}.opt"

BASE="${HOME}/script_rman"

NLS_DATE_FORMAT="yyyy/mm/dd hh24:mi:ss"
export NLS_DATE_FORMAT
TSTAMP=$(date +%Y%m%d%H%M)
TBACKUP=${SCRIPT_NAME#*.}
LOG="${BASE}/log/${ORACLE_SID}.${TBACKUP}.${TSTAMP}.log"

(
if [ "${TBACKUP}" != "CLEAN" ];then
	echo "run"
	echo "{"
	echo "allocate channel t1 type sbt parms 'ENV=(TDPO_OPTFILE=${TDPO_OPTFILE})' MAXOPENFILES 1;"
	echo "allocate channel t2 type sbt parms 'ENV=(TDPO_OPTFILE=${TDPO_OPTFILE})' MAXOPENFILES 1;"
	echo "allocate channel t3 type sbt parms 'ENV=(TDPO_OPTFILE=${TDPO_OPTFILE})' MAXOPENFILES 1;"
	echo "allocate channel t4 type sbt parms 'ENV=(TDPO_OPTFILE=${TDPO_OPTFILE})' MAXOPENFILES 1;"
	#INC0
	if [ "${TBACKUP}" == "INC0" ];then
		echo "backup as compressed backupset tag ${ORACLE_SID}_INC0 INCREMENTAL LEVEL=0 format '${ORACLE_SID}_full_%U_%s_%p' (database include current controlfile);"
		echo "backup as backupset full tag ${ORACLE_SID}_ARCH format '%d_%U_%s_%t_ARCH.bak' (archivelog all delete input);"
	fi
	#INC1
	if [ "${TBACKUP}" == "INC1" ];then
		echo "backup as compressed backupset tag ${ORACLE_SID}_INC1 INCREMENTAL LEVEL=1 CUMULATIVE format '${ORACLE_SID}_inc1_%U_%s_%p' (database include current controlfile);"
		echo "backup as backupset full tag ${ORACLE_SID}_ARCH format '%d_%U_%s_%t_ARCH.bak' (archivelog all delete input);"
	fi
	#ARCH
	if [ "${TBACKUP}" == "ARCH" ];then
		echo "backup as backupset full tag ${ORACLE_SID}_ARCH format '%d_%U_%s_%t_ARCH.bak' (archivelog all delete input);"
	fi
	echo "release channel t1;"
	echo "release channel t2;"
	echo "release channel t3;"
	echo "release channel t4;"
	echo "}"
fi
echo "allocate channel for maintenance device type disk;"
echo "allocate channel for maintenance type sbt parms 'ENV=(TDPO_OPTFILE=${TDPO_OPTFILE})';"
#CLEAN
if [ "${TBACKUP}" == "CLEAN" ];then
	echo "crosscheck backup;"
	echo "crosscheck archivelog all;"
	echo "delete noprompt expired backup;"
	echo "delete noprompt expired archivelog all;"
fi
echo "delete noprompt obsolete;"
echo "release channel;"
) > $BASE/rman/backup_${ORACLE_SID}.rman

RMAN="$BASE/rman/backup_${ORACLE_SID}.rman"
chown oracle:oinstall $BASE/rman/backup_${ORACLE_SID}.rman
chmod 755 $BASE/rman/backup_${ORACLE_SID}.rman

rman target / catalog ${CATALOG} cmdfile ${RMAN} msglog ${LOG}

retcode=$?
if [ ! $retcode -eq 0 ];then
  mv $LOG ${LOG}.nok
fi

exit $retcode
