
function dnetworks --description "Prints information about containers connected to each Docker network."
    # Get a list of all Docker network names
    set networks (docker network ls --format '{{.Name}}')

    # Iterate through each network
    for network in $networks
        echo "Network: $network"
        # Inspect the network and filter the output for container IDs
        docker network inspect $network --format '{{range .Containers}}{{.Name}} ({{.IPv4Address}}){{"\n"}}{{end}}'
        echo "-------------------------------------"
    end
end
