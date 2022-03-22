export LANG=en_US.UTF-8; export LC_CTYPE=en_US.UTF-8;
function LogInfo()      { $SETCOLOR_NORMAL; log="[INFO] $*"; echo -e $log; $SETCOLOR_NORMAL; }
function LogError()     { $SETCOLOR_FAILURE; log="[ERROR] $*"; echo -e $log; $SETCOLOR_NORMAL; }
function Abort()        { LogError "Abort."; exit 1; }
function CheckErr()     { if [ $? != 0 ]; then LogError "has any errors."; Abort; fi; }
function CheckStr()     { str=$1; if [ -z $str ]; then LogError "empty value."; Abort; fi; }
function CheckIp()      { ip=$1; if [ -z $ip ]; then LogError "no input ip addr."; Abort; fi; echo "check ip $ip ..."; ping -c 1 $ip 1>/dev/null 2>&1; if [ $? != 0 ]; then LogError "$ip is not reachable."; Abort; fi; }
function CheckFile()    { file=$1; if [ -z $file ]; then LogError "no input file."; Abort; fi; if [ ! -f $file ]; then LogError "file [$file] no exist."; Abort; fi; }
function CheckDir()     { dir=$1; if [ -z $dir ]; then LogError "no input dir."; Abort; fi; if [ ! -d $dir ]; then LogError "dir [$dir] no exist."; Abort; fi; }
function ModifyKey()    { key=$1; value=$2; confpath=$3; CheckStr $key; CheckStr $value; CheckFile $confpath; sed -i 's+<'"$key"'>.*</'"$key"'>+<'"$key"'>'"$value"'</'"$key"'>+g' $confpath; }
function ModifyProp()   { key=$1; value=$2; confpath=$3; CheckStr $key; CheckStr $value; CheckFile $confpath; sed -i 's+'"$key"'.*=.*+'"$key"'='"$value"'+g' $confpath; }
function BackupDir()    { dir=$1; if [ ! -d $dir ]; then return 0; fi; if [ -d ${dir}.backup ]; then rm -rf ${dir}.backup; fi; mv -f $dir ${dir}.backup; }
function BackupFile()   { file=$1; if [ ! -f $file ]; then return 0; fi; if [ -f ${file}.backup ]; then rm -f ${file}.backup; fi; mv -f $file ${file}.backup; }
function BackupDir2()   { dir=$1; CheckDir $dir; mv -f $dir $dir.$(date +%s); parentdir=$(dirname $dir); filename=$(basename $dir); num=0; for _backupdir in $(find $parentdir -name "$filename.*" -type d | sort -r); do ((++num)); if [ $num -gt 3 ]; then rm -rf $_backupdir; fi; done; }
function BackupFile2()  { file=$1; CheckFile $file; mv -f $file $file.$(date +%s); parentdir=$(dirname $file); filename=$(basename $file); num=0; for _backupfile in $(find $parentdir -name "$filename.*" -type f | sort -r); do ((++num)); if [ $num -gt 3 ]; then rm -vf $_backupfile; fi; done; }
function KillProc()     { match=$1; if [ -z $match ]; then Abort; fi; proclist=$(ps aux | grep "$match" | grep -v grep | awk '{print $2}'); for pid in $proclist; do kill $pid; done; }
function CloseFirwall() { systemctl stop firewalld; systemctl disable firewalld; setenforce 0; if [ $(grep -c "SELINUX=e" /etc/selinux/config) != 0 ]; then sed -i 's#SELINUX=e.*#SELINUX=disabled#g' /etc/selinux/config; fi; if [ $(grep -c "SELINUX=p" /etc/selinux/config) != 0 ]; then sed -i 's#SELINUX=p.*#SELINUX=disabled#g' /etc/selinux/config; fi; }
function CheckLocalIp() { local localip=$1; if [ -z $localip ]; then LogError "no input ip addr."; Abort; fi; echo "check localip ..."; if [ $(ifconfig | grep -c "$localip ") == 0 ]; then LogError "ip=$localip is not localip."; Abort; fi;  }
function ReplaceKey()   { key=$1; value=$2; confpath=$3;CheckStr $key; CheckStr $value; CheckFile $confpath; sed -i 's+'"${key}"'+'"${value}"'+g' $confpath; }

function Usage()
{
    echo -e "USAGE:"
    echo -e "  $0 install"
    echo -e "  $0 uninstall"
    exit 1
}