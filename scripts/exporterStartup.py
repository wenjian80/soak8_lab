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
	print "java weblogic.WLST exporterStartup.py -u username -p password -a adminUrl \n"
	sys.exit(2)
	
	
if __name__=='__main__' or __name__== 'main':

	try:
		opts, args = getopt.getopt(sys.argv[1:], "u:p:a:n:f:t:", ["username=", "password=", "adminUrl="])

	except getopt.GetoptError, err:
		print str(err)
		usage()

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
#Create startup class and deploy to admin, osb and soa
#========================		
def deployExporter():

	try:
		edit()
		startEdit()
		cd('/')	
		cmo.createStartupClass('exporter')
		cd('/StartupClasses/exporter')
		cmo.setClassName('weblogic.logging.exporter.Startup')
		set('Targets',jarray.array([ObjectName('com.bea:Name=AdminServer,Type=Server'),ObjectName('com.bea:Name=osb_cluster,Type=Cluster'),ObjectName('com.bea:Name=soa_cluster,Type=Cluster')], ObjectName))				
		save()
		activate()
	except:
		print 'Error create exporter class'

#========================
#Execute Block
#========================
username = ''
password = ''
adminUrl = ''
deploymentTarget = ''

for opt, arg in opts:
	if opt == "-u":
		username = arg
	elif opt == "-p":
		password = arg
	elif opt == "-a":
		adminUrl = arg

	
if username == "":
	print "Missing \"-u username\" parameter.\n"
	usage()
elif password == "":
	print "Missing \"-p password\" parameter.\n"
	usage()
elif adminUrl == "":
	print "Missing \"-a adminUrl\" parameter.\n"
	usage()
	
print '=============================================================================='
print 'Connecting to Admin Server...'
print '=============================================================================='
connectToDomain()
print '=============================================================================='
print 'Create Startup Class and deploy to Admin, Soa and osb cluster...'
print '=============================================================================='
deployExporter()
print '=============================================================================='
print 'Execution completed...'
print '=============================================================================='


disconnect()
exit()


