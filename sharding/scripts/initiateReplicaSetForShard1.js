rs.initiate(
  {
    _id: "shard1rs",
    members: [
      { _id : 0, host : "${eth0ip}:27020" },
      { _id : 1, host : "${eth0ip}:27021" },
      { _id : 2, host : "${eth0ip}:27022" }
    ]
  }
)

rs.status()