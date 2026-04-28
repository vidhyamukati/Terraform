# Terraform on Google Cloud Shell — Step-by-Step Guide

This README documents the complete workflow for initializing Terraform, generating a dependency graph, and visualizing infrastructure on Google Cloud Shell.

---

## Prerequisites

- Google Cloud Shell (or any Linux environment with Terraform installed)
- A valid `.tf` configuration file in your working directory
- Internet access to download Terraform providers

---

## Step 1 — Verify Your Terraform Configuration

Before initializing, confirm your `.tf` files are present in the working directory.

```bash
ls *.tf
```

If you have no `.tf` files, create a basic one. Example `main.tf`:

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = "YOUR_PROJECT_ID"
  region  = "us-central1"
}
```

---

## Step 2 — Initialize Terraform

Downloads and installs the required provider plugins (e.g., `hashicorp/google`).

```bash
terraform init
```

**Expected output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/google...
- Installing hashicorp/google v7.x.x...
- Installed hashicorp/google v7.x.x (signed by HashiCorp)

Terraform has been successfully initialized!
```

A `.terraform.lock.hcl` file is created to lock provider versions. Commit this to version control.

---

## Step 3 — Validate the Configuration

Check for syntax errors or misconfigurations before planning.

```bash
terraform validate
```

**Expected output:**
```
Success! The configuration is valid.
```

---

## Step 4 — Preview the Execution Plan

See what resources Terraform will create, modify, or destroy — without applying anything.

```bash
terraform plan
```

Review the output carefully. Resources marked with `+` will be created, `~` modified, `-` destroyed.

---

## Step 5 — Install Graphviz (if not already installed)

Graphviz provides the `dot` command used to render the dependency graph as an image.

```bash
sudo apt-get install -y graphviz
```

Verify installation:

```bash
dot -V
# dot - graphviz version 2.43.0 (0)
```

> **Note:** In Google Cloud Shell, graphviz is usually pre-installed. This step is a no-op if it already exists.

---

## Step 6 — Generate the Terraform Dependency Graph

Terraform can output a DOT-format graph of your resource dependencies.

```bash
# Generate and render directly to PNG
terraform graph -type=plan | dot -Tpng > graph.png
```

Or, save the intermediate DOT file first:

```bash
# Save DOT file
terraform graph -type=plan > graph.dot

# Render DOT file to PNG
dot -Tpng graph.dot -o graph.png
```

> ⚠️ **Common mistake:** Do NOT use `[input.dot](http://input.dot)` — that is a hyperlink, not a filename. Use plain `graph.dot` or whatever you named your file.

---

## Step 7 — View the Graph

### Option A — Download from Cloud Shell

```bash
cloudshell download graph.png
```

### Option B — Open in Cloud Shell Editor

Click the **Open Editor** button in Cloud Shell, then navigate to `graph.png` in the file browser.

### Option C — Serve it via a quick HTTP server

```bash
python3 -m http.server 8080
```

Then click **Web Preview** → **Preview on port 8080** in Cloud Shell.

---

## Step 8 — Apply the Configuration (Optional)

If you're ready to provision real infrastructure:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

---

## Step 9 — Destroy Resources (Cleanup)

To tear down all resources created by Terraform:

```bash
terraform destroy
```

Type `yes` when prompted.

---

## File Reference

| File | Description |
|---|---|
| `main.tf` | Primary Terraform configuration |
| `.terraform.lock.hcl` | Provider version lock file (commit this) |
| `.terraform/` | Local provider cache (do NOT commit) |
| `graph.dot` | Raw DOT-format dependency graph |
| `graph.png` | Rendered PNG of the dependency graph |
| `terraform.tfstate` | Current infrastructure state (handle carefully) |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `terraform init` fails | Check internet access and valid `.tf` syntax |
| `dot: can't open input.dot` | Use a plain filename like `graph.dot`, not a hyperlink |
| `graph.png` is empty | Run `terraform validate` first; ensure resources are defined |
| Provider download slow | Normal on first run; providers are cached after |
| `pip install graphviz` not working | Use `sudo apt-get install -y graphviz` instead — pip installs a Python wrapper, not the `dot` binary |

---

## Quick Reference — All Commands in Order

```bash
# 1. Check config files
ls *.tf

# 2. Initialize Terraform
terraform init

# 3. Validate config
terraform validate

# 4. Preview plan
terraform plan

# 5. Install Graphviz (if needed)
sudo apt-get install -y graphviz

# 6. Generate dependency graph
terraform graph -type=plan | dot -Tpng > graph.png

# 7. Download graph to your machine
cloudshell download graph.png

# 8. Apply infrastructure (when ready)
terraform apply

# 9. Destroy infrastructure (cleanup)
terraform destroy
```

---

*Generated for Google Cloud Shell — Terraform + Graphviz workflow*