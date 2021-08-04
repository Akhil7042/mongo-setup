rs.initiate(
  {
    _id: "shard2rs",
    members: [
      { _id : 0, host : "${eth0ip}:50004" },
      { _id : 1, host : "${eth0ip}:50005" },
      { _id : 2, host : "${eth0ip}:50006" }
    ]
  }
)

rs.status()