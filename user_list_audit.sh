#!/bin/bash
################################################################################################################
##Script name: user_list_audit                                                                                ##
##Script purpose: Checks the list of user name and their home directories from /etc/passwd, gets its checksum ##
##                and compare it with previously collected checksum to detect changes.                        ##
################################################################################################################

#Variables
export LIST_OF_USERS=/var/log/user_dir_list
export CURRENT_USERS=/var/log/current_users
export USER_CHANGES=/var/log/user_changes
export LOG_FILE=/var/log/userlist_audit_`date +'%d-%b-%Y-%H:%M:%S'`.log

#Creating the files if it doesn't exist. (for the first time/ after accidental deletion)
touch $LIST_OF_USERS
touch $CURRENT_USERS
touch $USER_CHANGES
touch $LOG_FILE

#List down the users, home directories in "/var/log/user_dir_list", check md5 and compare with previous to take action.
echo "Listing down the users and their home directories." > $LOG_FILE
cat /etc/passwd | cut -d: -f 1,6 > $LIST_OF_USERS
OLD_MD5=`cat $CURRENT_USERS`
echo "Previous MD5 is $OLD_MD5" >> $LOG_FILE
NEW_MD5=`md5 $LIST_OF_USERS|cut -d' ' -f4`
echo "New MD5 is $NEW_MD5" >> $LOG_FILE

if [ $OLD_MD5 == $NEW_MD5 ]
then
  echo "No changes in the list of users" >> $LOG_FILE
else
  echo "New Modifications found in the list of users, home directories" >> $LOG_FILE
  echo "Updating the file - /var/log/current_users with new MD5 and logging the timestamp in the file - /var/log/user_changes" >> $LOG_FILE
  echo `date +'%d-%b-%Y-%H:%M:%S'` "changes occurred." >> $USER_CHANGES
  echo $NEW_MD5 > $CURRENT_USERS
fi

#Removing the file - /var/log/user_dir_list and deleting all the logs but most recent 10.
rm -r $LIST_OF_USERS
rm -rf `ls -t /var/log/userlist_audit* | awk 'NR>10'`
exit
