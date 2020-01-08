#### local模式的代码片段
```
public class WCDemo {
    public static void main(String[] args) {
        TopologyBuilder builder = new TopologyBuilder();
        builder.setSpout("1", new WCSpout());
        builder.setBolt("2", new LineHandlerBolt(), 1).shuffleGrouping("1"); // 指定并行度以及上游到本地的分发策略
        builder.setBolt("3", new WCBolt()).shuffleGrouping("2");
        new LocalCluster().submitTopology("WC", new Config(), builder.createTopology());
    }
}
```