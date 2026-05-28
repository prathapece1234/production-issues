# terraform
terraform-gcp
⚙️ Prerequisites

Before you begin:

You have GCP project access (for example: arched-hybrid-473811-h2)
You have the gcloud CLI installed
Terraform is installed (dnf install -y terraform on RHEL/CentOS)

create terraform service account(Compute Admin
Service Account User
Service Usage Admin) with follow permission create json key. copy to the terraform server 

gcloud auth activate-service-account terraform-333@terraform-477614.iam.gserviceaccount.com --key-file=/data/terraform-key.json

gloud auth list

verify permission
gcloud projects get-iam-policy arched-hybrid-473811-h2 --format="table(bindings.role)"

🧱 Run Terraform

Inside your Terraform working directory:

terraform init
terraform apply   -var="credentials_file=terraform-key.json"   -var="parent_project_id=terraform-477614" --auto-approve

🧩 Folder Structure (Example)
/terraform-gcp/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform-key.json        # (Not recommended to commit)
└── README.md

**Windows PC**

If you're running terraform from your windows pc.. install terraform first from (https://developer.hashicorp.com/terraform/install)
move that .exe file into C:\Programfiles\Terraform. Then open search bar environment variables and edit and add the path in that.

Powercli check Terraform --version

Then for GCP gcloud cli also need to install. 
open Power shell and enter below: 
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")

then in CLI run: gcloud init
then check gcloud --version

gcloud auth activate-service-account terraform@arched-hybrid-473811-h2.iam.gserviceaccount.com --key-file="terraform.json"
gclound auth list

terraform init
terraform apply --auto-approve -var="credentials_file=terraform.json" -var="parent_project_id=arched-hybrid-473811-h2"
