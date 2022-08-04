# EngineSpeed

Setup Hive-Engine Super Quick. This is meant for setting up a hive-engine node super quick as long as you know what its doing. It uses the default configuration and is just there to get you setup while you do something else. If you don't understand much about it, don't use it.
 
This also does use Node.JS 16 and Mongo 5, which isn't recommended by the official docs. I do run both of those on most of my nodes though and they have worked well for me so it's what I set this script to use(it's mainly for my own use). For the time being, the usage instructions will point to gitlab(as well as cloning the repo once a PR from primersion's copy to the main repo is made) due to Github not supporting IPv6 and only supporting Gitlab supports both. 
 
 Usage: 
 ```
 wget https://gitlab.com/Rishi556/EngineSpeed/-/raw/main/install.sh
 chmod +x install.sh
 ./install.sh
 ```
 
 Thats the basics. Now there's more stuff that you can do with it to help you out.
 
 Flags:
 
 ```
 -w : Witness. Use this if you plan on setting up as a witness. This will auto fill your .env for you with your ip address and account name and priv active key. Default off.
 
 -a : Use this to give your hive username. Must provide a value. Default is empty.
 
 -p : Use this to give your hive priv active key. Must provide a value. Default is empty.
 
 -4 : Use this if you want to use a ipv4 address for your witness. Default is ipv6, and will attempt to failover to v4 if no v6 detected.
 
 -l : Light node. Use this if you want to run a light node. Default is off(fullnode).
 
 -s : Give your snapshot location. Must have trailing /. There's 2 possible choices, (https://snap.primersion.com/ and https://snap.rishipanthee.com/snapshots/ which is a mirror of primersion). Default is https://snap.rishipanthee.com/snapshots/.
 ```

 
Few usage examples:

Full Node, no witness, default snapshot location : ` ./install.sh`

Full Node, witness(username rishi556, key 5fake) using ipv6, default snapshot location : ` ./install.sh -w -a rishi556 -p 5fake`

Full Node, witness(username rishi556, key 5fake) using ipv4, primersion's snapshot location : ` ./install.sh -w -a rishi556 -p 5fake -4 -s https://snap.rishipanthee.com/snapshots/`

Light Node, no witness, default snapshot location : ` ./install.sh -l`

Light Node, witness(username rishi556, key 5fake) using ipv6, default snapshot location : ` ./install.sh -w -a rishi556 -p 5fake -l`

Just set the values to what works best for you and run with it. This is meant to be used on a FRESH server. 
