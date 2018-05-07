#/!bin/sh
###ElasticSearch启动关闭脚本

###	开启的集群通过参数进行传递,添加传递的内容.
cluster=$2

nodes=$(echo $cluster|tr "," "\n")

case "$1" in
  start)
	for node in $nodes;
	do
	echo "Starting ElasticSearch--->"$node
	ssh soft@$node "~/app/elasticsearch-5.4.3/bin/elasticsearch -d"
	sleep 5
	done;;
  stop)
        for node in $nodes;
	do
	port=`ssh soft@$node "jps -lm|grep Elasticsearch"|awk '{print $1}'`
	if [ -n "$port" ];then
		echo "Stoping ElasticSearch--->"$node
		ssh soft@$node "kill -9 $port"	
		sleep 5
	fi
	done;;
  restart)
        $0 stop
        $0 start
        ;;
  *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
esac

exit 0
