#!/bin/bash

# ============================================================
# COLOR
# ============================================================

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

# ============================================================
# START
# ============================================================

echo
echo "${BG_MAGENTA}${BOLD} Starting Execution ${RESET}"
echo

# ============================================================
# PROJECT
# ============================================================

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "(unset)" ]]; then
    echo "${RED}${BOLD}ERROR:${RESET} Project ID belum diset."
    exit 1
fi

echo "${CYAN}PROJECT ID :${RESET} $PROJECT_ID"

# ============================================================
# REGION
# ============================================================

read -p "Masukkan Region [contoh: us-central1]: " REGION

if [[ -z "$REGION" ]]; then
    echo "${RED}${BOLD}ERROR:${RESET} Region tidak boleh kosong."
    exit 1
fi

echo "${CYAN}REGION     :${RESET} $REGION"

# ============================================================
# RESOURCE NAMES
# ============================================================

LAKE_ID="customer-lake"
LAKE_DISPLAY="Customer-Lake"

ZONE_ID="public-zone"
ZONE_DISPLAY="Public-Zone"

ASSET_ID="customer-raw-data"
ASSET_DISPLAY="Customer Raw Data"

ENTRY_GROUP_ID="custom-entry-group"
ENTRY_GROUP_DISPLAY="Custom entry group"

TAG_TEMPLATE_ID="customer-data-tag-template"
TAG_TEMPLATE_DISPLAY="Customer Data Tag Template"

BUCKET="${PROJECT_ID}-customer-bucket"

# ============================================================
# TASK 1
# CREATE LAKE
# ============================================================

echo
echo "${YELLOW}${BOLD}[TASK 1] Creating Lake...${RESET}"

gcloud dataplex lakes create "$LAKE_ID" \
    --location="$REGION" \
    --display-name="$LAKE_DISPLAY"

if [[ $? -ne 0 ]]; then
    echo "${RED}${BOLD}ERROR:${RESET} Gagal membuat lake."
    exit 1
fi

echo "${GREEN}Lake berhasil dibuat.${RESET}"

# ============================================================
# TASK 1
# CREATE ZONE
# ============================================================

echo
echo "${YELLOW}${BOLD}[TASK 1] Creating Zone...${RESET}"

gcloud dataplex zones create "$ZONE_ID" \
    --lake="$LAKE_ID" \
    --location="$REGION" \
    --type=RAW \
    --resource-location-type=SINGLE_REGION \
    --display-name="$ZONE_DISPLAY" \
    --discovery-enabled \
    --labels=domain_type=source_data

if [[ $? -ne 0 ]]; then
    echo "${RED}${BOLD}ERROR:${RESET} Gagal membuat zone."
    exit 1
fi

echo "${GREEN}Zone berhasil dibuat.${RESET}"

# ============================================================
# TASK 2
# CREATE ENTRY GROUP
# ============================================================

echo
echo "${YELLOW}${BOLD}[TASK 2] Creating Entry Group...${RESET}"

gcloud dataplex entry-groups create "$ENTRY_GROUP_ID" \
    --location="$REGION" \
    --display-name="$ENTRY_GROUP_DISPLAY"

if [[ $? -ne 0 ]]; then
    echo "${RED}${BOLD}ERROR:${RESET} Gagal membuat entry group."
    exit 1
fi

echo "${GREEN}Entry Group berhasil dibuat.${RESET}"

# ============================================================
# TASK 3
# CREATE STORAGE BUCKET ASSET
# ============================================================

echo
echo "${YELLOW}${BOLD}[TASK 3] Attaching Cloud Storage Bucket...${RESET}"

echo "Bucket:"
echo "  gs://$BUCKET"
echo

gcloud dataplex assets create "$ASSET_ID" \
    --location="$REGION" \
    --lake="$LAKE_ID" \
    --zone="$ZONE_ID" \
    --resource-type=STORAGE_BUCKET \
    --resource-name="projects/$PROJECT_ID/buckets/$BUCKET" \
    --display-name="$ASSET_DISPLAY" \
    --discovery-enabled \
    --csv-header-rows=1 \
    --csv-delimiter="," \
    --csv-encoding=UTF-8

if [[ $? -ne 0 ]]; then
    echo "${RED}${BOLD}ERROR:${RESET} Gagal membuat asset."
    exit 1
fi

echo "${GREEN}Cloud Storage bucket berhasil di-attach sebagai asset.${RESET}"

# ============================================================
# TASK 4
# CREATE TAG TEMPLATE
# ============================================================

echo
echo "${YELLOW}${BOLD}[TASK 4] Creating Tag Template...${RESET}"

gcloud data-catalog tag-templates create "$TAG_TEMPLATE_ID" \
    --location="$REGION" \
    --display-name="$TAG_TEMPLATE_DISPLAY" \
    --field=id=data_owner,display-name="Data Owner",type=string \
    --field=id=pii_data,display-name="PII Data",type='enum(Yes|No)'

if [[ $? -ne 0 ]]; then
    echo "${RED}${BOLD}ERROR:${RESET} Gagal membuat Tag Template."
    exit 1
fi

echo "${GREEN}Tag Template berhasil dibuat.${RESET}"

# ============================================================
# SUMMARY
# ============================================================

echo
echo "${BG_GREEN}${BOLD} EXECUTION COMPLETED ${RESET}"
echo

echo "${CYAN}${BOLD}Project:${RESET}"
echo "  $PROJECT_ID"

echo
echo "${CYAN}${BOLD}Lake:${RESET}"
echo "  ID           : $LAKE_ID"
echo "  Display Name : $LAKE_DISPLAY"
echo "  Location     : $REGION"

echo
echo "${CYAN}${BOLD}Zone:${RESET}"
echo "  ID           : $ZONE_ID"
echo "  Display Name : $ZONE_DISPLAY"
echo "  Type         : RAW"
echo "  Location     : SINGLE_REGION"
echo "  Discovery    : ENABLED"
echo "  Label        : domain_type=source_data"

echo
echo "${CYAN}${BOLD}Asset:${RESET}"
echo "  ID           : $ASSET_ID"
echo "  Display Name : $ASSET_DISPLAY"
echo "  Bucket       : gs://$BUCKET"
echo "  Type         : STORAGE_BUCKET"
echo "  Discovery    : ENABLED"
echo "  CSV Header   : 1"
echo "  CSV Delimiter: ,"
echo "  CSV Encoding : UTF-8"

echo
echo "${CYAN}${BOLD}Entry Group:${RESET}"
echo "  ID           : $ENTRY_GROUP_ID"
echo "  Display Name : $ENTRY_GROUP_DISPLAY"
echo "  Location     : $REGION"

echo
echo "${CYAN}${BOLD}Tag Template:${RESET}"
echo "  ID           : $TAG_TEMPLATE_ID"
echo "  Display Name : $TAG_TEMPLATE_DISPLAY"
echo "  Data Owner   : STRING"
echo "  PII Data     : ENUM (Yes | No)"

echo
echo "${CYAN}${BOLD}Knowledge Catalog:${RESET}"
echo "${BLUE}https://console.cloud.google.com/dataplex/search?project=${PROJECT_ID}${RESET}"
echo