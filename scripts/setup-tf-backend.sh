#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# setup-tf-backend.sh
# Run this ONCE before creating the GitHub Actions pipeline.
# It creates the Azure Storage Account used as the Terraform remote backend.
# ─────────────────────────────────────────────────────────────────────────────

set -e

# ── Configuration — update these values ──────────────────────────────────────
RESOURCE_GROUP="rg-terraform-backend"
LOCATION="eastus"
STORAGE_ACCOUNT="sttfbackend$(openssl rand -hex 4)"  # must be globally unique
CONTAINER_NAME="tfstate"
# ─────────────────────────────────────────────────────────────────────────────

echo "▶ Logging into Azure..."
az login

echo "▶ Creating Resource Group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

echo "▶ Creating Storage Account: $STORAGE_ACCOUNT"
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --encryption-services blob \
  --output none

echo "▶ Creating Blob Container: $CONTAINER_NAME"
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --output none

echo ""
echo "✅ Backend storage created successfully!"
echo ""
echo "──────────────────────────────────────────────"
echo "  Add these as GitHub Secrets:"
echo "──────────────────────────────────────────────"
echo "  TF_BACKEND_RG        = $RESOURCE_GROUP"
echo "  TF_BACKEND_SA        = $STORAGE_ACCOUNT"
echo "  TF_BACKEND_CONTAINER = $CONTAINER_NAME"
echo "  TF_BACKEND_LOCATION  = $LOCATION"
echo "──────────────────────────────────────────────"
