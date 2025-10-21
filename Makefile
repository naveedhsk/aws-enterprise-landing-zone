SHELL := /bin/bash

.PHONY: init plan apply destroy fmt validate graph

TF ?= terraform

init:
	$(TF) init -upgrade

plan:
	$(TF) plan

apply:
	$(TF) apply -auto-approve

destroy:
	$(TF) destroy -auto-approve || true

fmt:
	$(TF) fmt -recursive

validate:
	$(TF) validate

graph:
	$(TF) graph | dot -Tsvg > tf-graph.svg && echo "Graph at tf-graph.svg"
