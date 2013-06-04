#!/bin/bash
if [[ -n $(git diff-tree --no-commit-id --name-only -r $GIT_COMMIT |grep product.json) ]]; then
  echo Updating App Catalog staging now after changes made to product.json
  echo curl -X PUT http://appcatalogstage.azurewebsites.net/entry --user catUser:CatsAreUs -d @product.json -H "Content-type: application/json"
else
  echo Skipping App Catalog update since no changes made to product.json
fi

