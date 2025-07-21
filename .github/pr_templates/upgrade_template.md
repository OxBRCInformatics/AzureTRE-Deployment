# Azure TRE Upgrade: v__FROM_VERSION__ → v__TO_VERSION__

## **Purpose**

This upgrade brings our Azure TRE from version __FROM_VERSION__ to __TO_VERSION__, including upstream improvements while preserving our custom OUH configurations and resource bundles.

## **What's Being Updated**

- **Core TRE Platform:** Updated to v__TO_VERSION__ with latest features and security fixes
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

## **Repository Issues Being Addressed**

- [ ] Issue #__XXX__: __DESCRIPTION__ - **Priority:** High
- [ ] Issue #__XXX__: __DESCRIPTION__ - **Priority:** Medium
- [ ] Issue #__XXX__: __DESCRIPTION__ - **Priority:** Low

## **Key Changes in v__TO_VERSION__**

- [ ] Review breaking changes in upstream CHANGELOG.md
- [ ] Check compatibility with custom VM templates
- [ ] Verify custom Porter bundle versions still work

## **Progress Updates**

*This section will be updated as the upgrade progresses*

**Next Steps:** Complete staging tests → Verify custom components → Get approval → Deploy to production
