# apollo-graphql-supergraph
Apollo GraphQL Subergraph demo

## Quickstart on local k8s


```sh
# Create kind cluster
make kind-create

# Deploy k8s resources in kind cluster
make k8s-deploy

# Test Query
make query-supergraph
```

Output would be like this if all successfully run:

```
kubectl run -it --rm=true temp-curl --image=curlimages/curl --restart=Never -- /bin/sh -c \
                "curl -X POST -H 'Content-Type: application/json' --data '{ \"query\": \"{allProducts{id,sku,createdBy{email,totalProductsCreated}}}\" }' http://router-service:4000/"
{"data":{"allProducts":[{"id":"apollo-federation","sku":"federation","createdBy":{"email":"support@apollographql.com","totalProductsCreated":1337}},{"id":"apollo-studio","sku":"studio","createdBy":{"email":"support@apollographql.com","totalProductsCreated":1337}}]}}pod "temp-curl" deleted
```

Then, port-forward `svc/router-service:4000` to `localhost:4000` using kubectl

```sh
kubectl port-forward svc/router-service 4000:4000
```

Finally access `localhost:4000`. You'll come up with the page like this

![](assets/apollo-sandbox.png)


## Build and push subgraph containers

```sh
make docker-build-subgraphs

make docker-push-subgraphs
```
