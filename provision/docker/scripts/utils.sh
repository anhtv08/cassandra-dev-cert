#!/bin/bash
verify_docker(){
    local docker_ids="$@"
    echo "List of cassandra nodes: $docker_ids"
    for docker_id in "$docker_ids"; do
        echo "Verifing the node - $docker_id"
        #echo docker exec -it $docker_id "/bin/bash; cqlsh 'desc keyspaces; quit;'; exit;"
    done

    echo "Verification is completed!"
}
get_cassandra_node(){
   docker_ids=$(docker ps -a | grep cassandra| awk '{print $1}')
}

