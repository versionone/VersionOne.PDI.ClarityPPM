#!/usr/bin/sh
if [[ -n $(git diff-tree --no-commit-id --name-only -r $GIT_COMMIT|grep catalog.json) ]]; then
  echo Updating App Catalog now after changes made to catalog.json
	curl -X PUT http://appcatalog.azurewebsites.net/appcatalog/entries -d @catalog.json -H "Content-type: application/json"
else
	echo Skipping App Catalog update since no changes made to catalog.json
fi
