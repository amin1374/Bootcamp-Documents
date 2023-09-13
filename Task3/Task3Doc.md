## Introduction to Orchestration

Containerization of services has greatly helped to launch platforms and software. With the increase of containers, tools called orchestrator were created to manage and add new features.

In microservice architecture, various and advanced tools appeared to deploy software and services. Facilities emerged that led all developers to tools such as Docker and Kubernetes for the stability of their software. One of the most important advantages of using such tools is the stability of services and software, and by creating transparency, both from the developer's point of view and from the user's point of view, the trust and desire of users to use the software has also increased. With the increase of containers, tools called orchestrator were created to manage and add new features. In fact, orchestrators are advanced tools that were created to create clustering in container management.

![Alt text]([image.png](https://github.com/amin1374/NeshanDocuments/blob/master/Task3/pictures/image.png)
The most important tools available in this field

## 1-Kubernetes

Kubernetes, often referred to as K8s, provides an environment for containerized applications to be deployed, run, and scaled across multiple host systems.

This robust and sophisticated suite is designed to automate many steps in the application lifecycle and, like a game of Tetris, selects containers for an assembly with optimal computing resources until the workload is finished. Other functions such as automatic repair and restart of containers in case of failure are among the tasks of this platform.

The main goal of this tool is to simplify the work of the technical team, because many tasks related to the deployment of applications, which were previously done manually, are done automatically with Kubernetes.
![Alt text](image-1.png)
 ### Kubernetes architecture

 ![Alt text](image.png)



## 2-Openshift
Redhat company has also provided a solution called OpenShift. Its Enterprise version is called Redhat Openshift, which is implemented both on-premise and on Private/Public Cloud. Its community version was originally called OpenShift Origin, but recently it is released under the name of OKD.

Some capabilities in Kubernetes are presented in a different way in Openshift, for example, in Kubernetes Helm Charts is used to install packages, or Ingress is used in network settings for the service cart, which is a kind of reverse proxy based on nginx, but in Openshift Templates are used as packages, or Route is used for the service network, which is based on F5-Big IP.

 ![Alt text](image.png)

 OpenShift, developed by Red Hat, is written in Go and AngularJS languages. It supports Java, Go, Node.js, Python, PHP, and Ruby, but can be extended to support other programming languages. OpenShift easily integrates with other DevOps tools and is Open Container Initiative (OCI) compliant for container and runtime hosting. It can use Docker containers, and since it's based on Kubernetes, it will be familiar to developers coming from those platforms.

Enterprises working with OpenShift are looking for a versatile platform with strict security policies, faster application deployment and dedicated support. These features make it a very attractive solution for large-scale projects or smaller companies that lack dedicated resources to manage, secure, and monitor their applications.

## Comparing Kubernetes with OpenShift
`Commercial vs Free`

The biggest difference between them is that Openshift is a subscription-based commercial product and Kubernetes is free to use as an open source project.
An OpenShift subscription includes a full set of tools and dedicated support. Kubernetes has community support and combines with other third-party tools for specific tasks or operations.

`security`

OpenShift has strict security policies from the beginning. For example, it requires minimum user privileges even for basic operations and also restricts Docker containers to run as simple images.
Kubernetes' security features require more complex configuration, as it lacks native authentication and authorization capabilities and relies on an API for use with third-party tools for this purpose. The security protocol is not as well defined as OpenShift, as there is no default encryption in a cluster, making K8s more vulnerable to attacks.

`Dashboard`

OpenShift provides a great user experience with a simple web console. A simple, form-based dashboard allows users to manage all resources in a clean and simple environment.
The Kubernetes user interface is more difficult. To access the graphical user interface (GUI), developers must install Kubernetes' dedicated dashboard, then initiate an authentication and authorization process to access it, as the interface doesn't even have a login page. More advanced developers won't have a problem with this, but it might be a hindrance for beginners right from the start.

`Updates and support`

OpenShift, as a commercial product, offers dedicated service, support and guidance to customers. Kubernetes, as a free, community-based, open-source project, will not. If developers run into problems with Kubernetes, they should rely on the experience of other developers in the forums and wait for their questions to be answered. OpenShift has a team of Red Hat engineers ready to help 24/7.

`Built-in vs. Third party`

The OpenShift suite includes features such as monitoring and networking by default. Prometheus and Grafana are two monitoring tools that warn about issues in the stack. With Open vSwitch, a native OpenShift solution, networking is enabled out of the box


## Technical differences between OpenShift and Kubernetes
`Integrated CI/CD`

CI, or Continuous Integration, is a DevOps best practice. CI means running automated tests to check whether the integration of changes in the original code does not break the application and to ensure that there are no integration challenges with each new commit. CD, or continuous delivery, occurs after or in conjunction with continuous integration. After the build phase, all code changes are deployed to the test and/or production environment.

OpenShift uses Jenkins, an automation server that provides source-to-image support and can be used as a CI server. Kubernetes also relies on a third-party tool called CircleCI to create a CI/CD stream.

`Image Registry`

Developers can set up a Docker registry on Kubernetes, but it does not provide an integrated image registry. On the other hand, Openshift has an integrated image registry for use with Red Hat or Docker Hub through a console that contains all the information about the image in the project.

`Deployment`

Openshift and Kubernetes have different approaches to deployment. OpenShift may seem more complicated, but it has added benefits, such as setting up for automated deployment.
Kubernetes implements components using controllers, while OpenShift uses a command. The OpenShift deployment command does not support multiple updates, but the Kubernetes deployment components can handle concurrent updates.

Kubernetes uses Helm, a set of YAML manifests designed to simplify the deployment of containerized applications. This approach is simpler than OpenShift templates, which lack the simplicity and complexity of Helm charts. OpenShift monopod deployment may not be effective in more complex scenarios.


## 3-Hasicorp Nomad
Nomad is an orchestration platform from Hashicorp that supports containers. It has a similar philosophy to kubernetes in managing applications at scale.

However, Nomad supports both containerized and non-containerized workloads. Nomad also comes with good integration of other Hashicorp tools such as Consul, Vault and terraform.

The primary uses for the Nomad are;
1- Container orchestration
2-Non-container program orchestration.
3- Automatic service network with console.


 ![Alt text](image.png)

The main difference between Nomad and Kubernetes is that Nomad is more versatile and lightweight. Nomad can work just as a simple task scheduler or take on heavier orchestration roles depending on the project's specifications.

Kubernetes comes as a full-featured platform with all its components. Nomad leaves out many components that can be added later if necessary, minimizing the need for external dependencies.

 ![Alt text](image.png)

`Installation`

Nomad is lightweight and easy to install. It comes as a simple binary that quickly deploys to a local development machine or cloud environment with the same stability and performance.
Kubernetes requires more time and resources to deploy, and the installation process is more complex. There are other lighter Kubernetes implementations that only cover a few full features. These are used for rapid development and testing, but do not translate well to production because they are prone to configuration inconsistencies.

`Scalability`

Kubernetes (as of release) claims to support clusters of up to 5,000 nodes with 300,000 containers and up to 150,000 pods.
Nomad demonstrated that it can scale to cluster sizes above 10,000 nodes. And the challenge of 2 million containers referenced in 2020 confirmed their claims of superior scalability performance.

`Networking`

In Kubernetes, pods communicate through a peer-to-peer network. This network model requires two CIDRs (classless inter-domain routers): one for node IP addressing and one for services.
In Nomad, every job gets an IP by default. The corresponding ports can then be accessed directly or through external proxies, using the host network, dynamic or static port forwarding with the help of the Consul component.

`Required specifications`

Kubernetes requires more hardware, which is used for longer-term, more capital-intensive projects in public cloud environments such as Google Cloud Platform, Azure, or AWS.
Nomad is suitable for smaller teams, with limited capacity for orchestration purposes, with shorter development timelines, working on hybrid or on-premise environments.

`languages`

Kubernetes uses YAML or JSON to define and deploy applications, Nomad uses Hashicorp Configuration Language (HCL).
HCL is both a syntax and an API designed by Hashicorp for building structured configuration formats
Load Balancing
A load balancer distributes incoming traffic from the Internet to front-end applications that are responsible for handling requests.
The most popular solution in Kubernetes for load balancing is Ingress, a specialized Kubernetes controller (very similar to a pod).
. Ingress includes a set of rules to manage traffic and a daemon to enforce them. These rules can be adapted for more advanced needs.
Nomad has functionality similar to Kubernetes' Ingress controller, which can easily adapt to configuration changes and scaling.

`Integration`

Nomad works with Docker just like Kubernetes and runs non-containerized workloads (Windows, Java).

`Graphical user interface (GUI)`

Both have attractive and functional dashboards that provide a clear and simple management experience.

## 5-Docker Swarm

In fact, it is a set of machines (physical servers or virtual machines) that all have Docker installed on them in swarm mode and form a single cluster. This cluster consists of a number of managers (or cluster masters) and a number of workers (or cluster minions), whose task is to manage the cluster and the task of the workers is to implement the desired services. A node in the cluster can be a manger, it can be a worker, or it can be both a manager and a worker. When we create a service in a Swarm cluster, we define the state we expect the service to reach and maintain.

For example, we specify features such as the number of replicas (for example, we want 3 copies of the service to run on 3 different nodes), the amount of required and available resources (such as CPU and RAM) and the ports we want it to expose. From here on, Dockerswarm managers will always try to keep our service in the state we have defined; For example, if one of the nodes of the cluster goes out of service, the managers will raise another replica of the service on another node.

One of the important advantages of Dockerswarm compared to running independent containers on Docker in normal mode is that the service can be changed without down-time, that is, it can be updated without the need to manually restart the service. Docker applies the new change to the service replicas in order, that is, after updating one replica, it goes to the next one, and as a result, the entire operation is performed without the need to restart the entire cluster.

When Docker is running in swarm mode, you can still run standalone containers on it; With the difference that any node can run independent containers, but only Swarm cluster managers can run Swarm services.

`Advantages and features of Docker Swarm`

Integration of Swarm cluster management with Docker Engine: Creating and managing a Swarm cluster and deploying services on it is done with the same Docker CLI, and no additional orchestration tools are needed to work with Swarm.

`Decentralized design`: the differences between different nodes (manger and worker) are handled at runtime, and this makes it possible to create all different nodes from a single image.

`Declarative model for defining services and applications`: Docker allows us to specify the desired state of our service using a declarative method.

`The possibility of increasing or decreasing the number of replicas (scaling)`: for each service, the number of running instances can be increased or decreased at any time; As a result, the swarm manager automatically adds new instances or deletes some previous instances.

`Always keeping the services in the defined state`: the manager node continuously checks the state of the cluster and if it sees a difference between the defined state and the current state of a service, it tries to eliminate this difference and always keeps the service in the same state. keep the state defined. For example, if we have defined that there are 10 replicas of a service, but 2 of these replicas are down due to one of the servers being down, the manager will raise these 2 instances to another healthy node to define the state. saved for this service.

`Service discovery`: Swarm cluster manger nodes give each service a unique DNS name and load balance between the running containers of this service during query.

`Load balancing`: DockerSwarm allows us to expose the ports of a service so that a load balancer can be used to distribute the load between different containers. Also, Swarm gives us the ability to specify how to distribute different containers to different nodes.

`High security`: By default, each node uses TLS authentication and encryption to provide maximum security for all communications between itself and other nodes.
The ability to update in the order of containers or Rolling updates: Dockerswarm allows us to update the containers of a service with a distance from each other, and this time delay between the update of one container and the update of the next container can also be set. As a result, we can apply various changes to our service without the need for down-time. Also, if there is a problem in applying the new changes, it is possible to go back to the previous version (roll back).


## Key concepts `(Nodes)`

![Alt text](image.png)

A node means an instance of Docker engine present in the swarm cluster. For example, when we install Docker on a computer and put it in swarm mode, this computer will be a node of our swarm cluster. You can have one or more nodes on a physical server, but in the production environment, the nodes of my cluster are usually located on different physical servers.

To deploy an application on Swarm cluster, we define our service to a manager node. This service is broken into a series of tasks and this node sends these tasks to worker nodes for execution.
The cluster manager nodes are also responsible for orchestrating and managing the cluster so that the services defined on the Swarm cluster are always in the required state. The manger nodes choose a leader among themselves, and the task of orchestration is in charge of the leader node.

On the other hand, the worker nodes receive and execute the tasks that the manager nodes send to them. By default, manager nodes also act as workers; It means that the services are also run on them. But the cluster can be configured in such a way that the manager nodes are only responsible for managing the cluster and are so-called manager-only. An agent is located on each worker node, which continuously informs the node manager about the status of the tasks assigned to that node, and thus the manager can manage and maintain the state of each worker.

### `ervices and tasks`

Service is the definition of work and tasks that must be executed on manager or worker nodes and is actually the main place of user interaction with Swarm cluster. When creating a new service, the user specifies which image to use and which commands to execute inside the created containers.

In services that have replication, the manager assigns tasks to the worker nodes of the cluster depending on the number of replicas requested by the user in the service definition.
For global services, Swarm executes a service task on all cluster nodes.

A task consists of a Docker container and commands that must be executed inside that container. task is the smallest scheduling atomic unit in Swarm. Manager nodes assign tasks to worker nodes depending on the number of replicas. The moment a task is assigned to a node, it cannot be transferred to another node; Either it runs on the node or it fails.

### `load balancing`

Swarm uses ingress load balancing to make available the services that we want to be seen from outside the Swarm cluster. For this purpose, it is possible that the Swaram manager automatically assigns a PublishedPort in the range of 30000-32767 to our desired service, and it is also possible to assign a specific port to it.

With such a mechanism, our service is easily available through the specified port (PublishedPort) on each node of the swarm cluster; Even if there is no container of that service on that node. In fact, all cluster nodes have the ability to route incoming traffic to an instance of our service.

In swarm mode, a DNS is automatically assigned to each service, and based on the DNS name of each service, the swarm manager distributes requests within the cluster between different services, which is actually an internal load balancing for the cluster.



## 5-Rancher

Rancher is an open source container orchestration tool. In core, it uses kubernetes as the container orchestrator.
Rancher provides the following functions.

   1. Centralized Cluster Provisioning that supports on-prem, cloud, and edge.
   2. Streamlined Kubernetes Operations by controlling cluster operations from a single console.
   3. Centralized Kubernetes Security through centralized user policies.
   4. Intuitive Workload Management using native kubernetes API or kubectl utility.
   5. Integrated Monitoring and Logging using Prometheus, Fluentd, and Grafana.
   6. Supports management for Amazon EKS clusters & Google Kubernetes Engine (GKE)
   7. Global Application Catalog to make application installation and upgrade easier.

![Alt text](image.png)

## 6-Mesos
Mesos is another cluster management tool that can handle container orchestration very efficiently. Created by Twitter for its own infrastructure and then open sourced. It is used by companies like eBay, Airbnb, etc. Mesos is not a dedicated tool for containers.

Mesos is not a dedicated tool for containers. Instead, you can use it to cluster VMs or physical machines to run workloads (big data, etc.) other than containers.
You can also run a Kubernetes cluster on top of a Mesos cluster.

![Alt text](image.png)



`Refrences`
```
https://devopscube.com/docker-container-clustering-tools/
https://www.imaginarycloud.com/blog/openshift-vs-kubernetes-differences/#:~:text=The%20biggest%20difference%20between%20them,of%20tools%20and%20dedicated%20support.
https://www.imaginarycloud.com/blog/nomad-vs-kubernetes/
```




































| Feature | Kubernetes | Nomad | Mesos | OpenShift | Docker Swarm |
|---|---|---|---|---|---|
| Popularity | **Most popular** | Less popular | Less popular | Less popular | Least popular |
| Feature richness | **Most feature-rich** | Less feature-rich | More feature-rich | More feature-rich | Least feature-rich |
| Ease of use | More complex | Easier to use | More complex | More complex | Easiest to use |
| Management complexity | More complex | Easier to manage | More complex | More complex | Easiest to manage |
| Flexibility | Less flexible | More flexible | More flexible | Most flexible | Least flexible |
| Cost | Free | Free | Free | Free | Free |
| Supported platforms | Linux, Windows, macOS | Linux, Windows, macOS | Linux, macOS | Linux, Windows, macOS | Linux, Windows, macOS |
| Supported schedulers | Kubernetes scheduler, third-party schedulers | Nomad scheduler | Mesos scheduler | Kubernetes scheduler, third-party schedulers | Docker Swarm scheduler |
| Built-in monitoring | Yes | No | No | Yes | No |
| Built-in logging | Yes | No | No | Yes | No |
| Self-healing | Yes | No | Yes | Yes | No |
| Networking | Kubernetes networking, third-party networking | Nomad networking | Mesos networking | Kubernetes networking, third-party networking | Docker Swarm networking |
| Security | Kubernetes security, third-party security | Nomad security | Mesos security | Kubernetes security, third-party security | Docker Swarm security |
| Documentation | Extensive documentation | Good documentation | Good documentation | Extensive documentation | Good documentation |
| Community support | Large and active community | Active community | Active community | Large and active community | Active community |
