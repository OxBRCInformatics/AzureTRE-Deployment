# Azure TRE Upgrade: vFROM_VERSION → vTO_VERSION

**TRE ID:** `<Update after first run>`

*delete this after*
`Find the TRE ID under the first step of the pipeline. Preparation > Get run id > using id of: XXXXXX`

## **Purpose**

This upgrade brings our Azure TRE from version FROM_VERSION to TO_VERSION, including upstream improvements while preserving our custom OUH configurations and resource bundles.

## **What's Being Updated**

- **Core TRE Platform:** Updated to vTO_VERSION with latest features and fixes
- **Custom User Resources:** OUH Linux/Windows VM templates maintained and updated
- **VM Images:** Custom VM images in `/vm-images` may need rebuilding
- **DevContainer:** Update from upstream repo version in `.devcontainer/devcontainer.json`
- **Priority Issues:** Addressing repository issues during this upgrade

## **Custom Components to Preserve**

- [ ] **User Resource Bundles:**
  - `templates/workspace_services/guacamole/user_resources/guacamole-azure-linuxvm-ouh2`
  - `templates/workspace_services/guacamole/user_resources/guacamole-azure-windowsvm-ouh2`
- [ ] **VM Image Templates:** Custom images in `/vm-images/templates/`
- [ ] **Oxford Azure TRE:** Consider updates made in v0.21.1


## **Testing Plan**

- [ ] Example test

## **Key Changes in vTO_VERSION**

- [ ] Review breaking changes in upstream CHANGELOG.md
- [ ] Check compatibility with custom VM templates
- [ ] Verify custom Porter bundle versions still work

## **Progress Updates**

*This section will be updated as the upgrade progresses*

**Next Steps:** Complete staging tests → Verify custom components → Get approval → Deploy to production
