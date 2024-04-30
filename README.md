# Project Findings - nicoleliu

- [Project Findings - nicoleliu](#Project---nicoleliu)
  - [Introduction](#introduction)
  - [Findings](#findings)

---

## Introduction

In this lab, I served the DistilBERT model from my AKS deployment by directly loading the model in the container. The tools used in the project are 
- Potery for managing libraries and dependencies
- Pytest for testing 
- Pydantic library for model input and output type definition and validation 
- Docker for packaking the code and Docker conatiner as well as Minikube for deploying the api locally 
- Redis for caching 
- Kustomize for k8s deployment into AKS 
- Istio for service mesh (ingress, gateway, virtual service)
- K6 for generating load test traffic
- Grafana for visualizing performance and monitoring metrics

## Findings

![k6 results](k6_screenshot.png)
![Grafana results](grafana_screenshot.png)

100% requests returned success code 200.
P99 indeed was <2s


