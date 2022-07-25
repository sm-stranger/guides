#!/bin/bash

wget -qO-  -t 1 -T 5 --post-data '{"jsonrpc": "2.0", "id":"dontcare", "method": "block", "params": {"finality": "final"}}' https://rpc.ankr.com/near | jq