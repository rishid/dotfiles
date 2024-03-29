#!/usr/bin/env sh
# @file Functions
# @brief Houses the functions that are included by `~/.bashrc` and `~/.zshrc`
# @description
#     This script is included by `~/.bashrc` and `~/.zshrc` to provide functions.

# show all the names (CNs and SANs) listed in the SSL certificate for a given domain
function certnames {
  if [ -z "${1}" ]; then
    echo "ERROR: No domain specified."
    return 1
  fi

  local domain="${1}"
  echo "testing ${domain} ..."
  echo # newline

  local tmp=$(echo -e "GET / HTTP/1.0\nEOT" | openssl s_client -connect "${domain}:443" 2>&1);

  if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
    local certText=$(echo "${tmp}" | openssl x509 -text -certopt "no_header, no_serial, no_version, no_signame, no_validity, no_issuer, no_pubkey, no_sigdump, no_aux");
    echo "Common Name:"
    echo # newline
    echo "  ${certText}" | grep "Subject:" | sed -e "s/^.*CN=//";
    echo # newline
    echo "Subject Alternative Name(s):"
    echo # newline
    echo "  ${certText}" | grep -A 1 "Subject Alternative Name:" | sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2
    return 0
  else
    echo "ERROR: Certificate not found.";
    return 1
  fi
}
