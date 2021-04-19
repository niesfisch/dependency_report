SHELL := /bin/bash

TOP_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
REPORT_DIR = ${TOP_DIR}/report
ANALYZERS_DIR = analyzers
CONFIG_FILE = ${HOME}/.dependency_report

report: analyze
	@cd ${TOP_DIR} && \
    ./generate_report.sh

init:
	@cd ${TOP_DIR} && \
	./init.sh

checkout_projects: init
	@cd ${TOP_DIR} && \
	./checkout_projects.sh

analyze: checkout_projects
	@cd ${TOP_DIR} && \
	./${ANALYZERS_DIR}/terraform.sh && \
	./${ANALYZERS_DIR}/gradle.sh && \
	./${ANALYZERS_DIR}/maven.sh


cleanup:
	@echo "Cleaning up..." && \
	./cleanup.sh

