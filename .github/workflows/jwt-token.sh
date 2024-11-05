#!/usr/bin/env bash
set -x
#set -o pipefail

client_id="1045288"  # Client ID as first argument

pem=$(cat .github/workflows/test-poc-sara.2024-11-03.private-key.pem)  # File path of the private key

now=$(date +%s)
iat=$((${now} - 60))  # Issues 60 seconds in the past
exp=$((${now} + 600))  # Expires 10 minutes in the future

b64enc() { openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'; }

header_json='{
    "typ":"JWT",
    "alg":"RS256"
}'
# Header encode
header=$(echo -n "${header_json}" | b64enc)

payload_json="{
    \"iat\":${iat},
    \"exp\":${exp},
    \"iss\":\"${client_id}\"
}"
# Payload encode
payload=$(echo -n "${payload_json}" | b64enc)

# Signature
header_payload="${header}.${payload}"

# Save the private key to a temporary file
private_key_file=$(mktemp)
echo -n "${pem}" > "${private_key_file}"

signature=$(
    openssl dgst -sha256 -sign "${private_key_file}" \
    <(echo -n "${header_payload}") | b64enc
)

# Clean up the temporary file
rm -f "${private_key_file}"

# Create JWT
JWT="${header_payload}.${signature}"
printf '%s\n' "JWT: $JWT"
