# Che + Quarkus live coding demo
## Introduction
This demo is meant to show Eclipse Che in action, with live coding and hot reload in Quarkus. The demo begins by showing a simple deployed application (React frontend + Quarkus backend), then loads a workspace with the backend code and modifies it.

The git repo hosting the code to be edited is available at https://github.com/amisevsk/che-quarkus-demo

## Setup
This demo is designed to run on minishift, but can be adapted relatively easily to other deployments (crc, a remote cluster).

1. Start minishift (recommended `10Gi` memory)
2. Create namespace (e.g. `che-quarkus-demo`) and deploy the basic application there using the `./scripts/deploy_main_app.sh` script.
  - Note that the templates used to deploy come from https://github.com/amisevsk/che-quarkus-demo and may need to be updated if there are changes there.
3. Set minishift environment
    ```
    eval $(minishift oc-env)
    eval $(minishift docker-env)
    ```
    and run `./scripts/pull_images.sh` to ensure images used in demo are present on the cluster.
  - See below for details on images used
4. Deploy Che (tested with Che 7.1)
5. Update plugin registry to use cached artifacts: `amisevsk/che-plugin-registry:demo` to avoid issues with downloading extensions during demo.

### Setup details
A few slightly-customized images are used in the demo. They can be rebuilt by following the steps below.
- In the Che deployment, a custom plugin registry with all artifacts cached is used (`amisevsk/che-plugin-registry:demo`). To rebuild this registry, see (at the time of writing) [my fork](https://github.com/amisevsk/che-plugin-registry/tree/cache-artifacts).
    ```
    docker build -t <image>:<tag> -f Dockerfile.caching .
    ```
- The images in the devfile are built off upstream images using the arbitrary user ID patch in the devfile registry repo:
  ```bash
  # In devfile registry arbitrary-users-patch folder
  docker build -t amisevsk/che-quarkus-builder:dev \
    --build-arg FROM_IMAGE="quay.io/quarkus/centos-quarkus-maven:19.2.0" .
  docker build -t amisevsk/che-quarkus-runner:dev \
    --build-arg FROM_IMAGE="registry.fedoraproject.org/fedora-minimal:30" .
  ```
  - Additionally, the dockerfile in this repo (`./dockerfiles/Dockerfile`) can be used to update the builder image to include maven artifacts, speeding up the initial build.
- The images used in the regular deployment of the demo app are built from the dockerfiles in the che-quarkus-demo repository.

# Script (timing: 15-20 minutes)
1. Show the regular app running on OpenShift
    - Show backend: quarkus landing page + `/posts` API endpoint serving JSON
    - Show frontend: basic react wrapper over the `/posts` endpoint.
2. Show Eclipse Che, explain what it is and its goals
3. Show the github project and devfile stored there: https://github.com/amisevsk/che-quarkus-demo
    - Explain what devfile is, what workspace are
4. Launch a che workspace by using a factory URL (`https://<che-server>/f?url=https://github.com/amisevsk/che-quarkus-demo`)
5. Demo live coding in Che:
    1. Open file `PostResource.java` to warm up Java language server
    2. Run the `compile quarkus:dev` task in console
    3. Show that backend is running, as it was in the dedicated deployment (main page, `/posts` endpoint)
        - While showing backend, copy the Theia route for the main server to make it easier to configure frontend later.
    4. Start the *frontend* server as well:
        - Open terminal into frontend workspace container, use `vi` to update `/app/env-config.js` to read `REACT_APP_BACKEND_HOST: <backend Theia endpoint>` instead of `localhost`
        - Run the `start frontend` task
    5. Demo full application running in the workspace. Note that the frontend container is the same image as is running in the deployed app.
    6. Start updating `PostResource.java` and reloading preview to show hot reloading. Suggestions:
        - Add a check for posts with empty title and content in the `add` method:
          ```java
          @POST
          public Response add(Post post) {
            if (Strings.isNullOrEmpty(post.getTitle()) || Strings.isNullOrEmpty(post.getContent())) {
              return Response.status(400).build();
            }
            posts.add(post);
            return Response.ok(posts).build();
          }
          ```
        - Implement `delete` method:
          ```java
          @GET
          public Response list() {
            List<Post> sorted = posts.stream()
                .sorted((e1, e2) -> -1 * e1.getTimestamp().compareTo(e2.getTimestamp()))
                .collect(Collectors.toList());
            return Response.ok(sorted).build();
          }
          ```
        - Implement post sorting in `list` method:
          ```java
          @GET
          public Response list() {
            List<Post> sorted = posts.stream()
                .sorted((e1, e2) -> -1 * e1.getTimestamp().compareTo(e2.getTimestamp()))
                .collect(Collectors.toList());
            return Response.ok(sorted).build();
          }
          ```
6. Demo debugging the project
    - The devfile includes a debug configuration that should connect successfuly so long as the `compile quarkus:dev` task is still running
7. (optional) You can also create a native build and run it, though the compile step can take a long time. This is done via the `package -Pnative` and `start native` tasks.
    - If you go do this, be sure to note that the native image can be run with less than `32Mi` memory limit!
