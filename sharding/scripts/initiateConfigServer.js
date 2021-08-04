rs.initiate(
  {
    _id: "cfgrs",
    configsvr: true,
    members: [
      { _id : 0, host : "${eth0ip}:27019" },
    ]
  }
)

rs.status()
