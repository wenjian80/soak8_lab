import sys
import os
import re
from java.lang import System
import getopt
#========================
#Usage Section
#========================
def usage():

	print "Usage:"
	print "java weblogic.WLST manageApplication.py -u username -p password -a adminUrl [:] -n deploymentName -f deploymentFile -t deploymentTarget\n"
	sys.exit(2)
#========================
#Connect To Domain
#========================

def connectToDomain():

	try:
		connect(username, password, adminUrl)
		print 'Successfully connected to the domain\n'

	except:
		print 'The domain is unreacheable. Please try again\n'
		exit()
#========================
#Checking Application Status Section
#========================

def appstatus(deploymentName, deploymentTarget):

	try:
		domainRuntime()
		cd('domainRuntime:/AppRuntimeStateRuntime/AppRuntimeStateRuntime')
		currentState = cmo.getCurrentState(deploymentName, deploymentTarget)
		return currentState
	except:
		print 'Error in getting current status of ' +deploymentName+ '\n'
		exit()
#========================
#Application undeployment Section
#========================

def undeployApplication():

	try:
		print 'stopping and undeploying ..' +deploymentName+ '\n'
		stopApplication(deploymentName, targets=deploymentTarget)
		undeploy(deploymentName, targets=deploymentTarget)
	except:
		print 'Error during the stop and undeployment of ' +deploymentName+ '\n'
#========================
#Applications deployment Section
#========================

def deployApplication():

	try:
		print 'Deploying the application ' +deploymentName+ '\n'
		deploy(deploymentName,deploymentFile,targets=deploymentTarget)
		startApplication(deploymentName)
	except:
		print 'Error during the deployment of ' +deploymentName+ '\n'
		exit()
#========================
#Input Values Validation Section
#========================

if __name__=='__main__' or __name__== 'main':

	try:
		opts, args = getopt.getopt(sys.argv[1:], "u:p:a:n:f:t:", ["username=", "password=", "adminUrl=", "deploymentName=", "deploymentFile=", "deploymentTarget="])

	except getopt.GetoptError, err:
		print str(err)
		usage()

username = ''
password = ''
adminUrl = ''
deploymentName = ''
deploymentFile = ''
deploymentTarget = ''

for opt, arg in opts:
	if opt == "-u":
		username = arg
	elif opt == "-p":
		password = arg
	elif opt == "-a":
		adminUrl = arg
	elif opt == "-n":
		deploymentName = arg
	elif opt == "-f":
		deploymentFile = arg
	elif opt == "-t":
		deploymentTarget = arg

if username == "":
	print "Missing \"-u username\" parameter.\n"
	usage()
elif password == "":
	print "Missing \"-p password\" parameter.\n"
	usage()
elif adminUrl == "":
	print "Missing \"-a adminUrl\" parameter.\n"
	usage()
elif deploymentName == "":
	print "Missing \"-n deploymentName\" parameter.\n"
	usage()
elif deploymentFile == "":
	print "Missing \"-c deploymentFile\" parameter.\n"
	usage()
elif deploymentTarget == "":
	print "Missing \"-c deploymentTarget\" parameter.\n"
	usage()

#========================
#Main Control Block For Operations
#========================

def deployUndeployMain():

		appList = re.findall(deploymentName, ls('/AppDeployments'))
		if len(appList) >= 1:
    			print 'Application'+deploymentName+' Found on server '+deploymentTarget+', undeploying application..'
			print '=============================================================================='
			print 'Application Already Exists, Undeploying...'
			print '=============================================================================='
    			undeployApplication()
			print '=============================================================================='
    			print 'Redeploying Application '+deploymentName+' on'+deploymentTarget+' server...'
			print '=============================================================================='
			deployApplication()
	   	else:
			print '=============================================================================='
			print 'No application with same name...'
    			print 'Deploying Application '+deploymentName+' on'+deploymentTarget+' server...'
			print '=============================================================================='
			deployApplication()
#========================
#Execute Block
#========================
print '=============================================================================='
print 'Connecting to Admin Server...'
print '=============================================================================='
connectToDomain()
print '=============================================================================='
print 'Starting Deployment...'
print '=============================================================================='
deployUndeployMain()
print '=============================================================================='
print 'Execution completed...'
print '=============================================================================='
disconnect()
exit()