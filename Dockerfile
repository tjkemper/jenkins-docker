FROM jenkins:2.7.4

MAINTAINER Taylor Kemper <tjkemper6@gmail.com>

### elevate permissions
USER root

### install curl
RUN apt-get update \
      && apt-get install -y sudo curl\
      && rm -rf /var/lib/apt/lists/*

# Install docker-engine
# According to Petazzoni's article:
# ---------------------------------
# "Former versions of this post advised to bind-mount the docker binary from
# the host to the container. This is not reliable anymore, because the Docker
# Engine is no longer distributed as (almost) static libraries."

# correct server version
ARG docker_version=1.11.2 
RUN curl -sSL https://get.docker.com/ | sh && \
    apt-get purge -y docker-engine && \
    apt-get install docker-engine=${docker_version}-0~jessie


# Install kubectl
RUN curl -O https://storage.googleapis.com/kubernetes-release/release/v1.4.3/bin/linux/amd64/kubectl \
    && chmod +x kubectl \
    && sudo cp kubectl /usr/local/bin/kubectl

# Give the jenkins user sudo privileges in order to be able to run Docker commands inside the container.
# see: http://container-solutions.com/running-docker-in-jenkins-in-docker/
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

### drop back to the regular jenkins user - good practice
# USER jenkins

# installing specific list of plugins. see: https://github.com/jenkinsci/docker#preinstalling-plugins
COPY plugins.txt /var/jenkins_home/plugins.txt
RUN /usr/local/bin/plugins.sh /var/jenkins_home/plugins.txt

############################################
# Configure Jenkins
############################################

### Jenkins Settings, i.e. Maven, Groovy, ...
COPY config/hudson.tasks.Maven.xml /usr/share/jenkins/ref/hudson.tasks.Maven.xml

# tell Jenkins that no banner prompt for pipeline plugins is needed
# see: https://github.com/jenkinsci/docker#preinstalling-plugins
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state




