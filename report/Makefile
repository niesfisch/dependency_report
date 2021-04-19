SHELL := /bin/bash

TOP_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VENV_DIR := ${TOP_DIR}/venv/

venv:	install_requirements

# jump into venv
# source venv/bin/activate
init_venv:
	@cd ${TOP_DIR} && \
	if [ ! -d "${VENV_DIR}" ]; then \
		echo "Creating virtualenv..." && \
		virtualenv ${VENV_DIR} -p $(shell which python3.8); \
	fi

install_requirements:	init_venv
	@echo "Checking requirements..." && \
	cd ${TOP_DIR} && \
	source ${VENV_DIR}/bin/activate && \
	pip install -r requirements.txt


