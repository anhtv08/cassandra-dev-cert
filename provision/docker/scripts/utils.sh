#!/bin/bash
verify_docker(){
    for docker_id in "${docker_ids[@]}"; do
        echo $docker_id
        #echo docker exec -it $docker_id "/bin/bash; cqlsh 'desc keyspaces; quit;'; exit;"
    done
}
