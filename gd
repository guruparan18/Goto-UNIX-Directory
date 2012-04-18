gd() { 

 #--- 
 # Author : Sree guruparan P A
 # Purpose: Used to remember, list and goto the directory needed.
 # Install: Copy paste the starting from gd(){ } into the shell.
 # Date   : April 17, 2012.

 num_of_elem=${#path_ar[*]}
 if [ $num_of_elem -eq 0 ]
 then
  path_ar=$PWD
 fi

 print_path(){
  i=0
  num_of_elem=${#path_ar[*]}

  while [ $i -lt $num_of_elem ]
  do
   echo "$i \t${path_ar[$i]}"
   ((i=i+1))
  done
  
  unset i
 }
 
 add_path(){
  to_add=$1
  
  if [ $# -eq 0 ];
  then
   to_add=$PWD
  fi
  
  num_of_elem=${#path_ar[*]}
  path_ar[$num_of_elem]=$to_add 
  
  print_path
 }
 
 goto_path(){
  goto_dir_pos=$1
  cd ${path_ar[$goto_dir_pos]} 
 }

 num_par=$#
 
 if [ $num_par -eq 0 ];
 then
  print_path
 else
  while getopts aglhrR: OPTION
  do
   case ${OPTION} in
        a) add_path $2
           ;;
        g) goto_path $2
           ;;
        l) print_path
           ;;
        h) print "Usage: gd -[aglh] [0-9|DIRECTORY]
  Example:
  gd -a /tmp  to add /tmp to the directories remembered.
  gd -a       to add \$PWD to the directories remembered.
  gd -l       to list all the directory remembered.
  gd -g 0     to goto directory in 0th position.
  gd -h       to list this help."
           ;;
        R) R_FLAG=TRUE;;
       0|9)n_FLAG=TRUE;;
       \?) print -u2 "Usage: ${PROG_NAME} [ -a -b -l logfile_name ]"
           exit 2;;
   esac
  done
 fi
}
