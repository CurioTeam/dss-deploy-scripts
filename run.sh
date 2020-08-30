ETH_FROM=0x8A591C424eC1f34f63085E01802C790C09410049 \
ETH_PASSWORD=./keystore/pwd \
ETH_KEYSTORE=./keystore \
ETH_RPC_URL=https://kovan.infura.io/v3/your-infura-key \
TMPDIR=/tmp \
dss-deploy kovan -f ./config/custom.json
