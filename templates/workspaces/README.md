# Workspace Templates

Workspace Templates are located in this folder.

| Template name | Description |
| --- | --- |
| [base](./base) | Base Azure TRE workspace with `workspace_type: base` tag and optional `project_name` tag |
| [airlock-import-review](./airlock-import-review) | Airlock Data Import Review workspace with `workspace_type: airlock_import_review` tag |
| [unrestricted](./unrestricted) | Unrestricted Azure TRE workspace with `workspace_type: unrestricted` tag |

These templates extend the core AzureTRE workspace templates with the following customisations:

- **`workspace_type` tag**: Each workspace resource group is tagged with a `workspace_type` tag indicating the type of workspace (e.g. `base`, `airlock_import_review`, `unrestricted`). This tag is applied to all Azure resources within the workspace via the `tre_workspace_tags` local variable.
- **`project_name` tag**: The base (and derived) workspace templates accept an optional `project_name` parameter. When provided, Azure resources are tagged with the project name to associate the workspace with a specific project. This tag is displayed in the TRE portal as "Project Name" during workspace creation.

For more detail on the Archive process, see SOP019 Archival of Projects in the Analysis Environment.
