# Logging using ELK for Weblogic Server logs#

The WebLogic Logging Exporter adds a log event handler to WebLogic Server, such that WebLogic Server logs can be integrated into Elastic Stack in Kubernetes directly, by using the Elasticsearch REST API.

Github Location: https://github.com/oracle/weblogic-logging-exporter

## Prerequisite ##
This document assumes that you have already deployed Elasticsearch/Kibana env. If you have not, please use a sample/demo deployment of Elasticsearch/Kibana from WebLogic Operator.

Please use the following command to deploy Elasticsearch/Kibana on the Kubernetes cluster,

```
kubectl create -f https://raw.githubusercontent.com/oracle/weblogic-kubernetes-operator/master/kubernetes/samples/scripts/elasticsearch-and-kibana/elasticsearch_and_kibana.yaml
```

Follow the following instructions to setup Weblogic Logging Exporter in a Weblogic operator/SOA environment and push the Weblogic server logs to Elasticsearch/Kibana


## 1. Download Weblogic logging exporter binaries ##

The Weblogic logging exporter pre-built binaries are available in the release page of the github - https://github.com/oracle/weblogic-logging-exporter/releases

Download weblogic-logging-exporter-0.1.1.jar from the github release link above. Also download dependency jar - snakeyaml-1.23.jar from Maven Central.


## 2. Copy JAR files to the Kubernetes Weblogic Domain Pod ##
Copy weblogic-logging-exporter-0.1.1.jar and snakeyaml-1.23.jar to the domain home folder in the Admin server pod.

```
kubectl cp snakeyaml-1.23.jar soans/soainfra-adminserver:/u01/oracle/user_projects/domains/soainfra/
 
kubectl cp weblogic-logging-exporter-0.1.1.jar soans/soainfra-adminserver:/u01/oracle/user_projects/domains/soainfra/
```

## 3. Add a startup class to your domain configuration ##
In this step, we configure weblogic-logging-exporter JAR as a startup class in the Weblogic servers where we intend to collect the logs.

In the Administration Console, navigate to "Environment" then "Startup and Shutdown classes" in the main menu.

a) Add a new Startup class. You may choose any descriptive name and the class name must be "weblogic.logging.exporter.Startup".
![enter image description here](https://github.com/wenjian80/soak8_lab/blob/main/img/startup1.png)
b) Target the startup class to each server that you want to export logs from.
![enter image description here](https://github.com/wenjian80/soak8_lab/blob/main/img/startup2.png)
c) You can verify this by checking for the update in your config.xml which should be similar to this example:

## 4. Update Weblogic Server CLASS Path. ##
In this step, we set the class path for weblogic-logging-exporter and its dependencies.

a) Copy setDomainEnv.sh from the pod to local folder.
```
 kubectl cp soans/soainfra-adminserver:/u01/oracle/user_projects/domains/soainfra/bin/setDomainEnv.sh .
```

b) Modify setDomainEnv.sh to update the Server Class path.
```
CLASSPATH=/u01/oracle/user_projects/domains/soainfra/weblogic-logging-exporter-0.1.1.jar:/u01/oracle/user_projects/domains/soainfra/snakeyaml-1.23.jar:${CLASSPATH}
export CLASSPATH
```

c) Copy back the modified setDomainEnv.sh to the pod.
```
kubectl cp setDomainEnv.sh soans-au01/soainfra-adminserver:/u01/oracle/user_projects/domains/soainfra/bin/setDomainEnv.sh
```

## 5. Create configuration file for the WebLogic Logging Exporter. ##
In this step, we will be creating the configuration file for weblogic-logging-exporter.

a) Create a file named WebLogicLoggingExporter.yaml. Specify the elasticsearch server host and port number.

```
weblogicLoggingIndexName: wls
publishHost: elasticsearch.default.svc.cluster.local
publishPort: 9200
domainUID: soainfra
weblogicLoggingExporterEnabled: true
weblogicLoggingExporterSeverity: TRACE
weblogicLoggingExporterBulkSize: 1
```

b) Copy file to the domain folder in the weblogic server pod.
```
kubectl cp WebLogicLoggingExporter.yaml soans-au01/soainfra-adminserver:/u01/oracle/user_projects/domains/soainfra/config/
```

## 6. Restart Weblogic Servers ##
Now we can restart the weblogic servers for the weblogic-logging-exporter to get loaded in the servers.

To restart the servers, edit the domain and change serverStartPolicy to NEVER for the weblogic servers to shutdow

```
$ kubectl edit domain -n soans
 
  serverService:
    annotations: {}
    labels: {}
  serverStartPolicy: NEVER
  webLogicCredentialsSecret:
    name: soainfra-domain-credentials
 
$ kubectl get pods -n soans
NAME                   READY     STATUS        RESTARTS   AGE
rcu                    1/1       Running       0          37d
soadb-0                1/1       Running       0          37d
soainfra-adminserver   0/1       Terminating   0          4d
soainfra-soa-server1   0/1       Terminating   0          4d
```

After all the server are shutdown edit domain again and set serverStartPolicy to IF_NEEDED for the servers to start again.
```
$ kubectl get pods -n soans
NAME                   READY     STATUS    RESTARTS   AGE
rcu                    1/1       Running   0          37d
soadb-0                1/1       Running   0          37d
soainfra-adminserver   1/1       Running   0          8m
soainfra-soa-server1   1/1       Running   0          7m
soainfra-soa-server2   1/1       Running   0          7m
```

In the server logs, you will be able to see the Weblogic-logging-exporter class being called.

```
======================= Weblogic Logging Exporter Startup class called 
================== Reading configuration from file name: /u01/oracle/user_projects/domains/soainfra/config/WebLogicLoggingExporter.yaml 
  
Config{weblogicLoggingIndexName='wls', publishHost='elasticsearch.default.svc.cluster.local', publishPort=9200, weblogicLoggingExporterSeverity='Notice', weblogicLoggingExporterBulkSize='1', enabled=true, weblogicLoggingExporterFilters=[
FilterConfig{expression='NOT(MSGID = 'BEA-000449')', servers=[]}], domainUID='soainfra'} 
====================== WebLogic Logging Exporter is ebled 
================= publishHost in initialize: elasticsearch.default.svc.cluster.local 
================= publishPort in initialize: 9200 

```

## 7. Create index pattern in Kibana ##
We need to create an index pattern in Kibana for the logs to be available in the dashboard.

Create an index pattern "wls*" in Kibana > Management. After the server starts, you will be able to see the log data from the weblogic servers in the Kibana dashboard,
```
======================= Weblogic Logging Exporter Startup class called  
================== Reading configuration from file name: /u01/oracle/user_projects/domains/soainfra/config/WebLogicLoggingExporter.yaml  
  
Config{weblogicLoggingIndexName='wls', publishHost='elasticsearch.default.svc.cluster.local', publishPort=9200, weblogicLoggingExporterSeverity='Notice', weblogicLoggingExporterBulkSize='1', enabled=true, weblogicLoggingExporterFilters=[
FilterConfig{expression='NOT(MSGID = 'BEA-000449')', servers=[]}], domainUID='soainfra'}  
====================== WebLogic Logging Exporter is ebled  
================= publishHost in initialize: elasticsearch.default.svc.cluster.local  
================= publishPort in initialize: 9200  
================= url in executePutOrPostOnUrl: http://elasticsearch.default.svc.cluster.local:9200/wls
soainfra-soa-server2   0/1       Terminating   0          4d
```
![enter image description here](https://github.com/wenjian80/soak8_lab/blob/main/img/startup3.png)
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTQzNDg2NTIxOV19
-->