This script automatically pull configuration record to be displayed in analytical platform (Redash localhost in my case).
Combine with orchestration such as Jenkins/Azure DevOps/AWS Pipeline for cycle pulling automatically.
![image](https://user-images.githubusercontent.com/101460772/158055549-e6c9063d-2d67-4e68-adb9-4ecd0947c0d8.png)
Can be used for similiar case to other cloud system/environment, provided API is supported.

Refference used/related in this repo:
- [xmlstarlet lib](http://xmlstar.sourceforge.net/)
- [jq lib](https://stedolan.github.io/jq/)
- [gcloud sdk](https://cloud.google.com/sdk/gcloud)
- [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/api/resources/azure-ad-overview?view=graph-rest-1.0)
- [GCP API](https://cloud.google.com/compute/docs/reference/rest/v1)
- [vCenter API](https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/)
- [PALO API](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-panorama-api.html)
- [NSX API](https://docs.vmware.com/en/VMware-NSX-Data-Center-for-vSphere/6.4/nsx_64_api.pdf)
