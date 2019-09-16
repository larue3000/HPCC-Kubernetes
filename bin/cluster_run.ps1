<#
.SYNOPSIS
HPCC Systems Cluster Operations
 
.DESCRIPTION
Get status/start/stop  HPCC Systems Cluster

 Usage:  cluster_run.ps1 -action <status/stop/start, default is status> -namespace <namespace, default is "default">
             -component <cluster name, such as myroxie1, mydali> -pod-name <Pod name> 
     
.Example
./cluster_run.ps1 -action status

.NOTES

.LINK
https://github.com/xwang2713/HPCC-Kubernetes

#>

param(
    $namespace="default",
    $component="",
    $pod_name="",
    $action="status"
)

$wkDir = split-path $myInvocation.MyCommand.path

$KUBECTL="kubectl.exe"
cd $wkDir
function get_cluster_status
{
  foreach ( $pod in (./cluster_query.ps1))
  {
      kubectl.exe exec $pod /etc/init.d/hpcc-init status
      ""
  }  
}

function runHPCC 
{
    if ( "$pod_name" -eq "" ) 
    {
        return 1
    }
   $cmd="${KUBECTL} exec $pod_name /etc/init.d/hpcc-init"
   if  ( $comp_name )
   {
      $cmd="$cmd -c $comp_name"
   }
   $cmd="$cmd $1"
   "$cmd"  
   iex "$cmd"

}

function runHPCCCluster
{
 @" 

###############################################
#
# $1 HPCC Cluster ...
#
###############################################
 "@
   $cmd="${KUBECTL} exec $admin_pod /opt/hpcc-tools/$1_hpcc.sh"
   "$cmd"
   iex "$cmd"

 @" 

###############################################
#
# Status:
#
###############################################
"@
   get_cluster_status
}

function stxxxHPCC
{
   if ( $action -ieq "restart" -or  ! $pod_name )
   {
       runHPCCCluster $1
       return
   }
   runHPCC $1
}



switch ( $action )
{
   "status" 
   { 
       get_clster_status
   }
   "start"  
   { 
       "start" 
   }
   "stop"  {"stop"}
   "restart" { "restart"}
}
