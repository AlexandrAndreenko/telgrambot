#!/bin/bash
if [[ $# -ne 3 ]]; then
    echo "usage: $0 srcBranch dstBranch prId"
    echo "example: $0 staging master 1618"
    exit 1
fi

debug() {
    if [ $2 -eq 1 ]; then
        echo $1 >> /home/deployer/log.txt
    fi
}

dryRun=0
srcBranch=$1
dstBranch=$2
prId=$3
backendBranch='/home/githubrunner/telgrambot'
bindir=/home/deployer/.local/bin

if [ -f /tmp/deployer-pr-lock-$prId ]; then
    debug "double $prId" 1
    exit 1;
fi
touch /tmp/deployer-pr-lock-$prId
cd $backendBranch
git checkout master
git pull
VERSIONFILE=`cat /home/deployer/backend/.ebextensions/files/scripts/deployment_cmd.sh |grep 'VERSION_TO_BE_DEPLOYED=' | awk -F'=' '{print $2}' | sed "s/'//g"`
currentTag=`git describe --abbrev=0 --tags`
debug "current tag: $currentTag" $dryRun

if [ ! -f /tmp/${VERSIONFILE} ]; then
        touch /tmp/${VERSIONFILE}
        aws s3 cp /tmp/${VERSIONFILE} s3://cw-deployment-lock/${VERSIONFILE} --region=eu-central-1
fi

if [ "$dstBranch" == "test2" ]; then
    git checkout staging
    git pull
    git checkout master
    git merge staging
    version=`echo $srcBranch|awk -F'-' '{print $2}'`
    debug "version $version" $dryRun
    if [ "$version" != "" ]; then 
        debug "git tag -a \"v$version\" -m \"Version $version\"" $dryRun
        debug "git push" $dryRun
        debug "git push --tags" $dryRun
        if [ $dryRun -ne 1 ]; then
            git tag -a "v$version" -m "Version $version"
            git push
            git push --tags
        fi
        while true; do
            debug "aws elasticbeanstalk describe-environment-health --environment-name cw-test-2 --attribute-name Status | jq -r .Status" $dryRun
            cwprod=`aws elasticbeanstalk describe-environment-health --environment-name cw-test-2 --attribute-name Status | jq -r .Status`
            debug "cwprod is $cwprod" $dryRun
            if [ "$cwprod" == "Ready" ]; then
                debug "./deployement.sh cw-test2" $dryRun
                if [ $dryRun -ne 1 ]; then
                    ./deployement.sh cw-test-2
                fi
                break
            else
               debug "cw prod is NOT ready, retrying" $dryRun 
            fi
        done

        while true; do 
            cwinstwrk=`aws elasticbeanstalk describe-environment-health --environment-name cw-worker-test-2 --attribute-name Status | jq -r .Status`
            debug "./deployement.sh cw-worker-test-2" $dryRun
            if [ "$cwinstwrk" == "Ready" ]; then
                if [ $dryRun -ne 1 ]; then
                ./deployement.sh cw-worker-test-2
                fi
                break
            else
                debug "cw instant is NOT ready, retrying" $dryRun
            fi
        done
    fi
    now=`date +%Y-%m-%d.%H:%M:%S`
    debug "aws s3 cp /home/deployer/logfile.txt s3://cw-middle-box/webhooklog-test-$now --region=eu-central-1" $dryRun
    debug "aws s3 cp /home/deployer/log.txt s3://cw-middle-box/daemonlog-test-$now --region=eu-central-1" $dryRun
    aws s3 cp /home/deployer/logfile.txt s3://cw-middle-box/webhooklog-test-$now --region=eu-central-1
    aws s3 cp /home/deployer/log.txt s3://cw-middle-box/daemonlog-test-$now --region=eu-central-1
    if [ $dryRun -ne 1 ]; then
        true > /home/deployer/logfile.txt
        true > /home/deployer/log.txt
    fi
elif [ "$dstBranch" == "main" ]; then
    debug "checkout master" $dryRun
    debug "git pull" $dryRun
    git checkout master
    git pull
    git checkout staging
    git merge master
    git commit
    git push
    git checkout master
    hfVersion=`echo $currentTag|awk -F'-' '{print $2}'`
    debug "hfVersion: $hfVersion" $dryRun
    if [ "$hfVersion" == "" ]; then
	#case no hf appended, increment last part of version, and append hf1
    	newVersion=`echo $currentTag|awk -F'.' '{print $1"."$2"."$3+1}'`
        version="${newVersion}-hf1"
    	version=`echo $version| awk -F'v' '{ print $2 }'`
    else
        newVersion=`echo $currentTag|awk -F'-hf' '{print $1"-hf"$2+1}'`
        version=`echo $newVersion| awk -F'v' '{print $2}'`
    fi
	debug "we got this as version $version" $dryRun
    if [ ${#newVersion} -gt 1 ]; then
            debug "git tag \"v$version\" -m \"Version $version\"" $dryRun
        if [ $dryRun -ne 1 ]; then
            git tag "v$version" -m "Version $version"
            git push --tags
        fi
        while true; do
            cwprod=`aws elasticbeanstalk describe-environment-health --environment-name cw-test-2 --attribute-name Status | jq -r .Status`
	        debug "zzz cwprod is $cwprod" $dryRun	
            if [ "$cwprod" == "Ready" ]; then
               debug "./deployement.sh cw-test-2" $dryRun 
                if [ $dryRun -ne 1 ]; then
                    ./deployement.sh cw-test-2
                else
                    debug "cw prod is NOT ready, retrying" $dryRun
                fi
                break
            fi
        done

        while true; do
            cwinstwrk=`aws elasticbeanstalk describe-environment-health --environment-name cw-worker-test-2 --attribute-name Status | jq -r .Status`
		    debug "zzz cwinstant is $cwinstwrk" $dryRun
            if [ "$cwinstwrk" == "Ready" ]; then
                debug "./deployement.sh cw-worker-test-2" $dryRun 
                if [ $dryRun -ne 1 ]; then
                    ./deployement.sh cw-worker-test-2
                else
                    debug "cw instant is NOT ready, retrying" $dryRun
                fi
                break
            fi
        done
    fi
    now=`date +%Y-%m-%d.%H:%M:%S`
    debug "aws s3 cp /home/deployer/logfile.txt s3://cw-middle-box/webhooklog-test-$now --region=eu-central-1" $dryRun
    debug "aws s3 cp /home/deployer/log.txt s3://cw-middle-box/daemonlog-test-$now --region=eu-central-1" $dryRun
    aws s3 cp /home/deployer/logfile.txt s3://cw-middle-box/webhooklog-test-$now --region=eu-central-1
    aws s3 cp /home/deployer/log.txt s3://cw-middle-box/daemonlog-test-$now --region=eu-central-1
    if [ $dryRun -ne 1 ]; then
        true > /home/deployer/logfile.txt
        true > /home/deployer/log.txt
    fi
fi
