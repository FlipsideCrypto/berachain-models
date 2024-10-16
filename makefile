DBT_TARGET ?= dev

deploy_new_github_action:
	dbt seed -s github_actions__workflows -t $(DBT_TARGET)
	dbt run -m "berachain_models,tag:gha_tasks" --full-refresh -t $(DBT_TARGET)
ifeq ($(findstring dev,$(DBT_TARGET)),dev)
	dbt run-operation fsc_utils.create_gha_tasks --vars '{"START_GHA_TASKS":False}' -t $(DBT_TARGET)
else
	dbt run-operation fsc_utils.create_gha_tasks --vars '{"START_GHA_TASKS":True}' -t $(DBT_TARGET)
endif

.PHONY: deploy_new_github_action