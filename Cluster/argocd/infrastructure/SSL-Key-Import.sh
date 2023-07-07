export vault_name="kv-oowzerotrustfpb"    


az keyvault secret set --name tls-key --vault-name $vault_name --file tls.key
az keyvault certificate import --file owainonline.pfx --name tls-cert --vault-name $vault_name


