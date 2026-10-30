# Web Lab

A small static site deployed to Azure App Service on the free tier.

The infrastructure is defined with Terraform. GitHub Actions deploys the contents of `src/` whenever you push to `main`. The site is locked down so only your IP can reach it.

## Requirements

You'll need the following installed and set up before you start:

- An Azure account (free tier is fine)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://developer.hashicorp.com/terraform/install) (1.5 or later)
- Git
- A GitHub account and a repository (you can create one as you go)

## What's in here

- `terraform/` – creates the resource group, free App Service plan, and App Service
- `src/` – the static site
- `.github/workflows/deploy.yml` – the deploy workflow

## Getting it running

### 1. Get your public IP

```bash
curl ifconfig.io
```

Copy the IP it prints. You'll need it in the next step.

### 2. Set your IP in Terraform

Create a file called `terraform/terraform.tfvars` and put your IP in it:

```hcl
home_ip = "1.2.3.4"
```

Replace `1.2.3.4` with the IP from the previous step. This is the file that controls who can reach the site.

### 3. Create the infrastructure

```bash
az login
cd terraform
terraform init
terraform apply
```

Type `yes` when it asks. Note the App Service name and URL from the outputs. The site is configured to only allow traffic from the IP you set above. Everyone else gets denied.

### 4. Create a service principal

```bash
az ad sp create-for-rbac --name "github-web-lab" --role contributor \
  --scopes /subscriptions/YOUR_SUB_ID/resourceGroups/rg-web-lab \
  --sdk-auth
```

Replace `YOUR_SUB_ID` with your subscription ID. You can get it with:

```bash
az account show --query id -o tsv
```

Copy the entire JSON it prints.

### 5. Add the secret to GitHub

In your repo: Settings → Secrets and variables → Actions → New repository secret.

- Name: `AZURE_CREDENTIALS`
- Value: the JSON from the previous step

### 6. Deploy

Push to `main` (or re-run the workflow from the Actions tab). The site should appear at the App Service URL after about a minute.

You can change the app name and resource group in the Terraform files if you want something different.

## Updating the site

Edit files in `src/`, commit, and push to `main`. The workflow will redeploy automatically.

## Changing your allowed IP later

1. Get your new IP with `curl ifconfig.io`.
2. Update `home_ip` in `terraform/terraform.tfvars`.
3. Run `terraform apply` again from the `terraform/` folder.

## License / usage

Feel free to copy, modify, and use this however you want. If you share it or put it in your own repo, include a link back to this GitHub repo.
